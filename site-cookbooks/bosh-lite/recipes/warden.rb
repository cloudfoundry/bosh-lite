include_recipe 'runit'
include_recipe 'bosh-lite::rbenv'

%w{ build-essential debootstrap quota iptables }.each { |package_name| package package_name }

rbenv_gem "bundler"

git "/opt/warden" do
  repository "git://github.com/cloudfoundry/warden.git"
  revision "9712451911c7a0fad149f83895169a4062c47fc3" #"2ab01c5fed198ee451837b062f0e02e783519289"
  action :sync
end

%w(config rootfs containers stemcells).each do |dir|
  directory "/opt/warden/#{dir}" do
    owner 'vagrant'
    mode 0755
    action :create
  end
end

%w(warden-cpi-vm.yml).each do |config_file|
  cookbook_file "/opt/warden/config/#{config_file}" do
    owner 'vagrant'
  end
end

execute "rbenv rehash"

execute "setup_warden" do
  cwd "/opt/warden/warden"
  command "/opt/rbenv/shims/bundle install && /opt/rbenv/shims/bundle exec rake setup:bin[/opt/warden/config/warden-cpi-vm.yml]"
  action :run
end

10.upto(138) do |i|
  execute "mknod /dev/loop#{i} b 7 #{i}" do
    not_if { ::File.exists?("/dev/loop#{i}") }
  end
end

%w(warden).each do |service_name|
  runit_service service_name do
    default_logger true
    options({:user => 'vagrant'})
  end
end
