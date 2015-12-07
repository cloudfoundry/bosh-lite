# BOSH Lite

* IRC: [`#bosh` on freenode](http://webchat.freenode.net/?channels=bosh)
* Mailing lists:
  - [cf-bosh](https://lists.cloudfoundry.org/pipermail/cf-bosh) for asking BOSH usage and development questions
  - [cf-dev](https://lists.cloudfoundry.org/pipermail/cf-dev) for asking CloudFoundry questions
* CI: <https://bosh-lite.ci.cf-app.com/pipelines/bosh-lite>
* Roadmap: [Pivotal Tracker](https://www.pivotaltracker.com/n/projects/956238) (label:bosh-lite)

A local development environment for BOSH using Warden containers in a Vagrant box.

This readme walks through deploying Cloud Foundry with BOSH Lite. BOSH and BOSH Lite can be used to deploy just about anything once you've got the hang of it.

1. [Install BOSH Lite](#install-bosh-lite)
    1. [Prepare the Environment](#prepare-the-environment)
    1. [Install and Boot a Virtual Machine](#install-and-boot-a-virtual-machine)
    1. [Customizing the Local VM IP](#customizing-the-local-vm-ip)
1. [Deploy Cloud Foundry](#deploy-cloud-foundry)
1. [Troubleshooting](#troubleshooting)
1. [Upgrading the BOSH Lite VM](#upgrading-the-bosh-lite-vm)
1. [Miscellaneous](#miscellaneous)

## Install BOSH Lite

### Prepare the Environment

1. Install latest version of `bosh_cli`

   ```
   $ gem install bosh_cli --no-ri --no-rdoc
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

1. When you are not using your VM we recommmend to *Pause* the VM from the VirtualBox UI (or use `vagrant suspend`), so that VM can be later simply resumed after your machine goes to sleep or gets rebooted. Otherwise, your VM will be halted by the OS and you will have to recreate previously deployed software.

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

See [deploying Cloud Foundry documentation](http://docs.cloudfoundry.org/deploying/boshlite/deploy_cf_boshlite.html) for detailed instructions. Alternatively, check out [CF Release](https://github.com/cloudfoundry/cf-release) as `~/workspace/cf-release` and run `./bin/provision_cf` from this repository.

## Troubleshooting

* [See troubleshooting doc](docs/troubleshooting.md) for solutions to common problems

## Upgrading the BOSH Lite VM

If you wish to upgrade the BOSH Lite VM, you can run the following commands from the root of the `bosh-lite` directory. Make sure you have the latest version of this repository checked out. WARNING: these operations are destructive, and essentially amount to starting from scratch.

```
$ vagrant box update
$ vagrant destroy
$ vagrant up --provider=DESIRED_PROVIDER
```

## Miscellaneous

* [bosh cck documentation](docs/bosh-cck.md) for restoring deployments after VM reboot
* [bosh ssh documentation](docs/bosh-ssh.md) for SSH into deployment jobs
* [Offline documentation](docs/offline-dns.md) to configure BOSH lite firewall rules
* [xip.io](http://xip.io) to access local IPs via DNS
* [Dev documentation](docs/dev.md) to find out how to build custom bosh-lite boxes
