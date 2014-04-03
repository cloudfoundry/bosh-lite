include_recipe 'runit'
include_recipe 'bosh-lite::rbenv'

%w{ debootstrap quota iptables }.each { |package_name| package package_name }

git "/opt/warden" do
  repository "git://github.com/cloudfoundry/warden.git"
  action :sync
end

cookbook_file "/tmp/0001-replace-SNAT-with-MASQ.patch"

execute "patch_warden" do
  cwd "/opt/warden"
  command "grep -q MASQ warden/root/linux/net.sh || git apply /tmp/0001-replace-SNAT-with-MASQ.patch"
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

execute "setup_warden" do
  cwd "/opt/warden/warden"
  command "/opt/rbenv/shims/bundle install && /opt/rbenv/shims/bundle exec rake setup:bin[/opt/warden/config/warden-cpi-vm.yml]"
  action :run
end

%w(warden).each do |service_name|
  runit_service service_name do
    default_logger true
    options({:user => 'vagrant'})
  end
end
