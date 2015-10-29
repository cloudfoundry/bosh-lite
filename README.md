# BOSH Lite

* IRC: [`#bosh` on freenode](http://webchat.freenode.net/?channels=bosh)
* Mailing lists:
  - [cf-bosh](https://lists.cloudfoundry.org/pipermail/cf-bosh) for asking BOSH usage and development questions
  - [cf-dev](https://lists.cloudfoundry.org/pipermail/cf-dev) for asking CloudFoundry questions
* CI: <https://main.bosh-ci.cf-app.com/pipelines/bosh-lite>
* Roadmap: [Pivotal Tracker](https://www.pivotaltracker.com/n/projects/956238) (label:bosh-lite)

A local development environment for BOSH using Warden containers in a Vagrant box.

This readme walks through deploying Cloud Foundry with BOSH Lite. BOSH and BOSH Lite can be used to deploy just about anything once you've got the hang of it.

1. [Install BOSH Lite](#install-bosh-lite)
    a. [Prepare the Environment](#prepare-the-environment)
    b. [Install and Boot a Virtual Machine](#install-and-boot-a-virtual-machine)
    c. [Customizing the Local VM IP](#customizing-the-local-vm-ip)
2. [Deploy Cloud Foundry](#deploy-cloud-foundry)
3. [Upgrading the BOSH Lite VM](#upgrading-the-bosh-lite-vm)
4. [Troubleshooting](#troubleshooting)
5. [Miscellaneous](#miscellaneous)

## Install BOSH Lite

### Prepare the Environment

1. Install latest version of `bosh_cli`

   ```
   $ gem install bosh_cli
   ```

   Refer to [BOSH CLI installation instructions](http://docs.cloudfoundry.org/bosh/bosh-cli.html) for more information and troubleshooting tips.

1. Install [Vagrant](http://www.vagrantup.com/downloads.html)

    Known working version:

    ```
    $ vagrant --version
    Vagrant 1.6.3
    ```

1. Clone this repository

    ```
    $ cd ~/workspace
    $ git clone https://github.com/cloudfoundry/bosh-lite
    ```

### Install and Boot a Virtual Machine

Installation instructions for different Vagrant providers:

* VirtualBox (below)
* [AWS](docs/aws-provider.md)

#### Using the VirtualBox Provider

1. Make sure your machine has at least 8GB RAM, and 100GB free disk space. Smaller configurations may work.

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

    Known working version:

    ```
    $ VBoxManage --version
    4.3.14r95030
    ```

    Note: If you encounter problems with VirtualBox networking try installing [Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads) as suggested by [Issue 202](https://github.com/cloudfoundry/bosh-lite/issues/202).

1. Start Vagrant from the base directory of this repository, which contains the Vagrantfile. The most recent version of the BOSH Lite boxes will be downloaded by default from the Vagrant Cloud when you run `vagrant up`. If you have already downloaded an older version you will be warned that your version is out of date.

    ```
    $ vagrant up --provider=virtualbox
    ```

1. Target the BOSH Director. When prompted to log in, use admin/admin.

    ```
    # if behind a proxy, exclude both the VM's private IP and xip.io by setting no_proxy (xip.io is introduced later)
    $ export no_proxy=xip.io,192.168.50.4

    $ bosh target 192.168.50.4 lite
    Target set to `Bosh Lite Director'

    $ bosh login
    Your username: admin
    Enter password: *****
    Logged in as `admin'
    ```

1. Add a set of route entries to your local route table to enable direct Warden container access every time your networking gets reset (e.g. reboot or connect to a different network). Your sudo password may be required.

    ```
    $ bin/add-route
    ```

### Customizing the Local VM IP

The local VMs (virtualbox, vmware providers) will be accessible at `192.168.50.4`. You can optionally change this IP, uncomment the `private_network` line in the appropriate provider and change the IP address.

```
  config.vm.provider :virtualbox do |v, override|
    # To use a different IP address for the bosh-lite director, uncomment this line:
    # override.vm.network :private_network, ip: '192.168.59.4', id: :local
  end
```

## Deploy Cloud Foundry

See [deploying Cloud Foundry documentation](http://docs.cloudfoundry.org/deploying/boshlite/deploy_cf_boshlite.html) for detailed instructions. Alternatively run `./bin/provision_cf` from this repository.

## Upgrading the BOSH Lite VM

If you wish to upgrade the BOSH Lite VM, you can run the following commands from the root of the `bosh-lite` directory. Make sure you have the latest version of this repository checked out. WARNING: these operations are destructive, and essentially amount to starting from scratch.

```
$ vagrant box update
$ vagrant destroy
$ vagrant up --provider=DESIRED_PROVIDER
```

## Troubleshooting

* Starting over again is often the quickest path to success; you can use `vagrant destroy` from the base directory of this project to remove the VM.
* Another option is to use `bosh cleanup`. This will clean up the blob store to free up some space on the virtual machine.
* There is an issue (discussed [here](https://groups.google.com/a/cloudfoundry.org/forum/m/#!topic/bosh-users/n2qYrpPUJaE) and [here](https://github.com/mitchellh/vagrant/issues/3589)) with Vagrant permissions running on OS X Mavericks 10.9.2+ (after applying [Apple's Security Update 2014-002](http://support.apple.com/en-us/HT202966)). To diagnose, run `vagrant up --debug` and see if there is an error mentioning `Symbol not found: _iconv`. To resolve try one of the two
  1. Purging vagrant

     Purging ~/.vagrant.d

     Reinstalling vagrant

  2. Removing code block as described [here](https://github.com/mitchellh/vagrant/issues/3589#issuecomment-42255427)

## Miscellaneous

* [bosh cck documentation](docs/bosh-cck.md) for restoring deployments after VM reboot
* [bosh ssh documentation](docs/bosh-ssh.md) for SSH into deployment jobs
* [Offline documentation](docs/offline-dns.md) to configure BOSH lite firewall rules
* [xip.io](http://xip.io) to access local IPs via DNS
* [Dev documentation](docs/dev.md) to find out how to build custom bosh-lite boxes
