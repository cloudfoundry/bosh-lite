Vagrant.configure('2') do |config|
  config.vm.box = 'cloudfoundry/bosh-lite'

  config.vm.provider :virtualbox do |v, override|
    override.vm.box_version = '9000.37.0' # ci:replace
    # To use a different IP address for the bosh-lite director, uncomment this line:
    # override.vm.network :private_network, ip: '192.168.59.4', id: :local
  end

  config.vm.provider :aws do |v, override|
    override.vm.box_version = '9000.37.0' # ci:replace
    v.elastic_ip = true
    # To turn off public IP echoing, uncomment this line:
    # override.vm.provision :shell, id: "public_ip", run: "always", inline: "/bin/true"

    # To turn off CF port forwarding, uncomment this line:
    # override.vm.provision :shell, id: "port_forwarding", run: "always", inline: "/bin/true"

    # Needed for Vagrant 1.7 since it loads Vagrantfile before downloading the box
    env = ENV.to_hash
    v.access_key_id = env.fetch('BOSH_AWS_ACCESS_KEY_ID')
    v.secret_access_key = env.fetch('BOSH_AWS_SECRET_ACCESS_KEY')
    v.ami = ''
  end
end
