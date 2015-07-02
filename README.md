# BOSH Lite

* IRC: [`#bosh` on freenode](http://webchat.freenode.net/?channels=bosh)
* Mailing lists:
  - [cf-bosh](https://lists.cloudfoundry.org/pipermail/cf-bosh) for asking BOSH usage and development questions
  - [cf-dev](https://lists.cloudfoundry.org/pipermail/cf-dev) for asking CloudFoundry questions
* CI: http://lite.bosh-ci.cf-app.com:8080
* Roadmap: [Pivotal Tracker](https://www.pivotaltracker.com/n/projects/956238) (label:bosh-lite)

A local development environment for BOSH using Warden containers in a Vagrant box.

This readme walks through deploying Cloud Foundry with BOSH Lite. BOSH and BOSH Lite can be used to deploy just about anything once you've got the hang of it.

## Install BOSH Lite

### Prepare the Environment

1. Install latest version of `bosh_cli`.

   ```
   $ gem install bosh_cli
   ```

   Refer to [BOSH CLI installation instructions](http://docs.cloudfoundry.org/bosh/bosh-cli.html) for more information and troubleshooting tips.

1. Install [Vagrant](http://www.vagrantup.com/downloads.html).

    Known working version:

    ```
    $ vagrant --version
    Vagrant 1.6.3
    ```

1. Clone this repository.

    ```
    $ cd ~/workspace
    $ git clone https://github.com/cloudfoundry/bosh-lite
    ```

### Install and Boot a Virtual Machine

Installation instructions for different Vagrant providers:

* Virtualbox (below)
* [AWS](docs/aws-provider.md)

#### Using the Virtualbox Provider

1. Install Virtualbox

    Known working version:

    ```
    $ VBoxManage --version
    4.3.14r95030
    ```

    Note: If you encounter problems with VirtualBox networking try installing [Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads) as suggested by [Issue 202](https://github.com/cloudfoundry/bosh-lite/issues/202).

1. Start Vagrant from the base directory of this repository, which contains the Vagrantfile. The most recent version of the BOSH Lite boxes will be downloaded by default from the Vagrant Cloud when you run `vagrant up`. If you have already downloaded an older version you will be warned that your version is out of date. You can use the latest version by running `vagrant box update`.

    ```
    $ vagrant up --provider=virtualbox
    ```

1. Target the BOSH Director. When prompted to log in, use admin/admin.

    ```
    # if behind a proxy, exclude both the VM's private IP and xip.io by setting no_proxy (xip.io is introduced later)
    $ export no_proxy=192.168.50.4,xip.io

    $ bosh target 192.168.50.4 lite
    Target set to `Bosh Lite Director'
    Your username: admin
    Enter password: *****
    Logged in as `admin'
    ```

1. Add a set of route entries to your local route table to enable direct Warden container access every time your networking gets reset (e.g. reboot or connect to a different network). Your sudo password may be required.

    ```
    $ bin/add-route
    ```

#### Customizing the local VM IP

The local VMs (virtualbox, vmware providers) will be accessible at `192.168.50.4`. To change this IP, uncomment the `private_network` line in the appropriate provider and change the IP address.

```
  config.vm.provider :virtualbox do |v, override|
    # To use a different IP address for the bosh-lite director, uncomment this line:
    # override.vm.network :private_network, ip: '192.168.59.4', id: :local
  end
```

## Deploy Cloud Foundry

* See [deploying Cloud Foundry documentation](docs/deploy-cf.md)

## Misc

* [bosh cck documentation](docs/bosh-cck.md) for restoring deployments after VM reboot
* [bosh ssh documentation](docs/bosh-ssh.md) for SSH into deployment jobs
* [Offline documentation](docs/offline-dns.md) to configure BOSH lite firewall rules
* [xip.io](http://xip.io) to access local IPs via DNS

## Troubleshooting

* Starting over again is often the quickest path to success; you can use `vagrant destroy` from the base directory of this project to remove the VM.
* Another option is to use `bosh cleanup`. This will clean up the blob store to free up some space on the virtual machine.
* There is an issue (discussed [here](https://groups.google.com/a/cloudfoundry.org/forum/m/#!topic/bosh-users/n2qYrpPUJaE) and [here](https://github.com/mitchellh/vagrant/issues/3589)) with Vagrant permissions running on OS X Mavericks 10.9.2+ (after applying [Apple's Security Update 2014-002](http://support.apple.com/en-us/HT202966)). To diagnose, run `vagrant up --debug` and see if there is an error mentioning `Symbol not found: _iconv`. To resolve try one of the two
  1. Purging vagrant

     Purging ~/.vagrant.d

     Reinstalling vagrant

  2. Removing code block as described [here](https://github.com/mitchellh/vagrant/issues/3589#issuecomment-42255427)

## Manage your local boxes

We publish pre-built Vagrant boxes on Amazon S3. It is recommended to use the latest boxes. To do so get a latest copy of the Vagrantfile from this repo and run `vagrant up`.
