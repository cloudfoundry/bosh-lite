# bosh-lite

A lite development env for BOSH using Warden from within vagrant

## Installation

Below are two installation processes, including deployment of Cloud Foundry.

* Vagrant (VMWare Fusion)
* AWS

### Vagrant / VMWare Fusion

1. Install Fusion 

1. [Install vagrant](http://downloads.vagrantup.com/)

1. Install vagrant Fusion Plugin + license

    ```
    vagrant plugin install vagrant-vmware-fusion
    vagrant plugin license vagrant-vmware-fusion license.lic
    ```

1. Install Ruby + RubyGems + Bundler
1. Run Bundler

    ```
    bundle
    ```

1. Run Librarian

    ```
    librarian-chef install
    ```

1. Start vagrant

    ```
    vagrant up --provider vmware_fusion
    ```

1. Bosh target (login with admin/admin)

    ```
    bosh target 192.168.50.4
    ```
    
1. Download latest warden stemcell

    ```
    wget http://bosh-jenkins-gems-warden.s3.amazonaws.com/stemcells/latest-bosh-stemcell-warden.tgz
    ```
    
1. Upload Stemcell
 
    ```
    bosh upload stemcell latest-bosh-stemcell-warden.tgz
    ```

1. Generate CF deployment manifest

    ```
    cp manifests/cf-stub.yml manifests/[your-name-manifest].yml
    bosh deployment manifests/[your-name-manifest].yml
    bosh diff [cf-release]/templates/cf-aws-template.yml.erb
    ./scripts/transform.rb -f manifests/[your-name-manifest].yml
    ```

1. Create CF release (form cf-release repo bosh-lite branch)
1. Deploy!

###USE AWS provider

1. Install Vagrant AWS provider

    ```
    vagrant plugin install vagrant-aws
    ```

1. Add dummy AWS box

    ```
    vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
    ```

1. Rename Vagrantfile.aws to Vagrantfile
1. Source your bosh_enviroment file

    ```
    source path/to/bosh_environment
    ```

1. Make sure the EC2 secure group you are using in the `Vagrantfile` exists and allows tcp/25555
1. Run Vagrant:

    ```
    vagrant up --provider=aws
    ```

