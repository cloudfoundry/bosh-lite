Vagrant.configure('2') do |config|
  config.vm.hostname='bosh-lite'

  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  config.vm.provider :virtualbox do |v, override|
    override.omnibus.chef_version = "10.26.0"
    v.customize ["modifyvm", :id, "--memory", 6*1024]
    v.customize ["modifyvm", :id, "--cpus", 4]
  end

  config.vm.provider :vmware_fusion do |v, override|
    override.vm.box_url = 'http://files.vagrantup.com/precise64_vmware.box'
    v.vmx["numvcpus"] = "4"
    v.vmx["memsize"] = 6 * 1024
  end

  config.vm.network :private_network, ip: '192.168.50.4'

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['cookbooks', 'site-cookbooks']

    chef.add_recipe 'bosh-lite::apt-update'
    chef.add_recipe 'build-essential::default'
    chef.add_recipe 'bosh-lite::warden'
    chef.add_recipe 'bosh-lite::bosh'
    chef.add_recipe 'bosh-lite::update-kernel'
    chef.add_recipe 'bosh-lite::reboot'
  end
end

