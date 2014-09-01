# better error messages from Hash.fetch
env = ENV.to_hash

unless env.include?('BOSH_AWS_ACCESS_KEY_ID') &&  env.include?('BOSH_AWS_SECRET_ACCESS_KEY')
  raise 'BOSH_AWS_ACCESS_KEY_ID and BOSH_AWS_SECRET_ACCESS_KEY must be provided in the environment'
end

def tags_from_environment(env)
  values = [env.fetch('BOSH_LITE_NAME', 'Vagrant')]
  values.concat env.fetch('BOSH_LITE_TAG_VALUES', '').chomp.split(', ')

  keys = ['Name']
  keys.concat env.fetch('BOSH_LITE_TAG_KEYS', '').chomp.split(', ')

  raise 'Please provide the same number of keys and values!' if keys.length != values.length

  Hash[keys.zip(values)]
end

Vagrant.configure('2') do |config|
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.provision :shell, :inline => "chmod 777 /tmp", :upload_path => '/opt/bosh-provisioner/packer-shell.sh'

  config.vm.hostname='bosh-lite'
  config.ssh.username = 'ubuntu'
  config.ssh.private_key_path = env.fetch('BOSH_LITE_PRIVATE_KEY', '~/.ssh/id_rsa_bosh')

  config.vm.provider :aws do |v|
    v.access_key_id =       env.fetch('BOSH_AWS_ACCESS_KEY_ID')
    v.secret_access_key =   env.fetch('BOSH_AWS_SECRET_ACCESS_KEY')
    v.keypair_name =        env.fetch('BOSH_LITE_KEYPAIR', 'bosh')
    v.block_device_mapping = [{
      :DeviceName => '/dev/sda1',
      'Ebs.VolumeSize' => env.fetch('BOSH_LITE_DISK_SIZE', '50').to_i
    }]
    v.instance_type =       env.fetch('BOSH_LITE_INSTANCE_TYPE', 'm3.xlarge')
    v.security_groups =     [env.fetch('BOSH_LITE_SECURITY_GROUP', 'inception')]
    v.subnet_id =           env.fetch('BOSH_LITE_SUBNET_ID') if env.include?('BOSH_LITE_SUBNET_ID')
    v.tags =                tags_from_environment(env)
  end

  PUBLIC_IP = <<-PUBLIC_IP_SCRIPT
public_ip=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
echo "The public IP for this instance is $public_ip"
echo "You can bosh target $public_ip, or run vagrant ssh and then bosh target 127.0.0.1"
  PUBLIC_IP_SCRIPT
  config.vm.provision :shell, id: "public_ip", run: "always", inline: PUBLIC_IP

  PORT_FORWARDING = <<-IP_SCRIPT
local_ip=`curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
echo "Setting up port forwarding for the CF Cloud Controller..."
sudo iptables -t nat -A PREROUTING -p tcp -d $local_ip --dport 80 -j DNAT --to 10.244.0.34:80
sudo iptables -t nat -A PREROUTING -p tcp -d $local_ip --dport 443 -j DNAT --to 10.244.0.34:443
sudo iptables -t nat -A PREROUTING -p tcp -d $local_ip --dport 4443 -j DNAT --to 10.244.0.34:4443
  IP_SCRIPT
  config.vm.provision :shell, id: "port_forwarding", run: "always", inline: PORT_FORWARDING
end
