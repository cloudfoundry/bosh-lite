Vagrant.configure('2') do |config|
  config.vm.box = 'cloudfoundry/bosh-lite'

  config.vm.provider :virtualbox do |v, override|
    override.vm.box_version = '9000.137.0' # ci:replace
    # To use a different IP address for the bosh-lite director, uncomment this line:
    # override.vm.network :private_network, ip: '192.168.59.4', id: :local
  end

  config.vm.provider :aws do |v, override|
    override.vm.box_version = '9000.137.0' # ci:replace
    # To turn off public IP echoing, uncomment this line:
    # override.vm.provision :shell, id: "public_ip", run: "always", inline: "/bin/true"

    # To turn off CF port forwarding, uncomment this line:
    # override.vm.provision :shell, id: "port_forwarding", run: "always", inline: "/bin/true"

    # Following minimal config is for Vagrant 1.7 since it loads this file before downloading the box.
    # (Must not fail due to missing ENV variables because this file is loaded for all providers)
    v.access_key_id = ENV['BOSH_AWS_ACCESS_KEY_ID'] || ''
    v.secret_access_key = ENV['BOSH_AWS_SECRET_ACCESS_KEY'] || ''
    v.region = ENV['BOSH_AWS_REGION'] || 'us-east-1'
    v.ami = ''
  end

  config.vm.provider :vmware_fusion do |v, override|
    override.vm.box = 'cloudfoundry/no-support-for-bosh-lite-on-fusion'
    #we no longer build current boxes for vmware_fusion
    #ensure that this fails. otherwise the user gets an old box
  end

  config.vm.provider :vmware_workstation do |v, override|
    override.vm.box = 'cloudfoundry/no-support-for-bosh-lite-on-workstation'
    #we no longer build current boxes for vmware_workstation
    #ensure that this fails. otherwise the user gets an old box
  end
end
