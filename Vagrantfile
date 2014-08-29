Vagrant.configure('2') do |config|
  config.vm.define 'bosh-lite'
  config.vm.box = 'bosh-lite-ubuntu-trusty'

  config.vm.provider :virtualbox do |v, override|
    #CDN in front of bosh-lite-build-artifacts.s3.amazonaws.com
    override.vm.box_url = 'http://d3a4sadvqj176z.cloudfront.net/bosh-lite/latest/bosh-lite-virtualbox-ubuntu-14-04-0.box'
  end
end
