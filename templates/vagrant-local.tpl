VM_MEMORY = ENV.fetch('VM_MEMORY', 6*1024).to_i
VM_CORES = ENV.fetch('VM_CORES', 4).to_i

Vagrant.configure('2') do |config|
  config.vm.network :private_network, ip: '192.168.50.4'
  config.vm.hostname='bosh-lite'

  config.vm.provider :virtualbox do |vbox, override|
    vbox.customize ['modifyvm', :id, '--memory', VM_MEMORY]
    vbox.customize ['modifyvm', :id, '--cpus', VM_CORES]
    vbox.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vbox.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  [:vmware_fusion, :vmware_desktop, :vmware_workstation].each do |provider|
    config.vm.provider provider do |vmware, override|
      vmware.vmx["numvcpus"] = VM_CORES
      vmware.vmx["memsize"] = VM_MEMORY
    end
  end
end
