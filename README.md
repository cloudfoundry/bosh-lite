# bosh-lite

A lite development env for BOSH using Warden from within Vagrant.

This readme also includes demonstrates how to deploy Cloud Foundry into bosh-lite.

## Installation

For all use cases, first prepare this project with `bundler` & `librarian-chef`.

1. [Install vagrant](http://downloads.vagrantup.com/)

    Known to work for version:
    ```
    $ vagrant -v
    Vagrant 1.3.5
    ```
    Note: for OSX and VirtualBox you are required to use Vagrant 1.3.4+

1. Install Vagrant omnibus plugin
    ```
    vagrant plugin install vagrant-omnibus
    ```
1. Install Ruby + RubyGems + Bundler

1. Run Bundler from the base directory of this repository

    ```
    bundle
    ```

1. Run Librarian

    ```
    librarian-chef install
    ```

Below are installation processes for different Vagrant providers.

* VMWare Fusion
* Virtualbox
* AWS

### USE VMWare Fusion Provider

Known to work with Fusion version 5.0.3

1. Install vagrant Fusion Plugin + license

    ```
    vagrant plugin install vagrant-vmware-fusion
    vagrant plugin license vagrant-vmware-fusion license.lic
    ```


1. Start vagrant from the base directory of this repository (which uses the Vagrantfile)

    ```
    vagrant up --provider vmware_fusion
    ```

1. Bosh target (login with admin/admin)

    ```
    bosh target 192.168.50.4
    Target set to `Bosh Lite Director'
    Your username: admin
    Enter password: admin
    Logged in as `admin'
    ```

1. Add a set of route entries to your local route table to enable direct warden container access. Your sudo password may be required.

    ```
    scripts/add-route
    ```

###USE Virtualbox Provider


1. Start vagrant from the base directory of this repository (which uses the Vagrantfile)

    ```
    vagrant up
    ```

1. Bosh target (login with admin/admin)

    ```
    bosh target 192.168.50.4
    Target set to `Bosh Lite Director'
    Your username: admin
    Enter password: admin
    Logged in as `admin'
    ```

1. Add a set of route entries to your local route table to enable direct warden container access every time your networking gets reset (eg. reboot or connect to a different network). Your sudo password may be required.

    ```
    scripts/add-route
    ```

###USE AWS Provider

1. Install Vagrant AWS provider

    ```
    vagrant plugin install vagrant-aws
    ```

1. Add dummy AWS box

    ```
    vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
    ```

1. Rename Vagrantfile.aws to Vagrantfile
1. Set environment variables called `BOSH_AWS_ACCESS_KEY_ID` and `BOSH_AWS_SECRET_ACCESS_KEY` with the appropriate values.  If you've followed along with other documentation such as [these steps to deploy Cloud Foundry on AWS](http://docs.cloudfoundry.com/docs/running/deploying-cf/ec2/index.html#deployment-env-prep), you may simply need to source your `bosh_environment` file.
1. Make sure the EC2 secure group you are using in the `Vagrantfile` exists and allows inbound TCP traffice on ports 25555 (for the BOSH director) and 22 (for SSH).
1. Run Vagrant from the base directory of this repository (which uses the Vagrantfile):

    ```
    vagrant up --provider=aws
    ```

1. Bosh target (login with admin/admin)

    ```
    bosh target 192.168.50.4
    Target set to `Bosh Lite Director'
    Your username: admin
    Enter password: admin
    Logged in as `admin'
    ```

## Troubleshooting

1. If you want to start over again, you can use `vagrant destroy` from the base directory of this project to remove the VM.
1. To start with a new VM just execute the appropriate `vagrant up` command optionally with the provider option as shown in the earlier sections.

## Upload Warden stemcell

bosh-lite uses the Warden CPI, so we need to use the Warden Stemcell which will be the root file system for all Linux Containers created by the Warden CPI.

1. Upload the latest warden stemcell

    ```
    bosh upload stemcell http://bosh-jenkins-gems-warden.s3.amazonaws.com/stemcells/latest-bosh-stemcell-warden.tgz
    ```

## Deploy Cloud Foundry



1.  Use the make_manifest_spiff script to create a cf manifest.  This step assumes you have cf-release checked out to ~/workspace and that you have [spiff](https://github.com/vito/spiff) installed.

    make_manifest_spiff will target your bosh-lite director, find the uuid, create a manifest stub and run spiff to generate a manifest at manifests/cf-manifest.yml.

    ```
    ./scripts/make_manifest_spiff
    ```

1.  Bosh target 192.168.50.4 and run bosh as normal, passing your generated manifest:
    ```
    cd ~/cf-release
    bosh create release
    # enter the name from the deployment-stub.yml file  - for example, 'cf'
    bosh upload release
    bosh deployment /path/to/bosh-lite/manifests/cf-manifest.yml
    bosh deploy
    ```
1.  Run the yeti tests against your new deployment to make sure it's working correctly.

    a.  Set the environment variables VCAP_BVT_API_ENDPOINT, VCAP_BVT_ADMIN_USER, VCAP_BVT_ADMIN_USER_PASSWD

    Might look like this:

    ```
    # This is the HA Proxy ip in bosh vms (not the cc)
    export VCAP_BVT_API_ENDPOINT=http://api.10.244.0.34.xip.io
    export VCAP_BVT_ADMIN_USER=admin
    export VCAP_BVT_ADMIN_USER_PASSWD=admin
    ```

    b.  Run yeti as normal from cf-release/src/tests.. e.g.

    ```
    rake config:clear_bvt # clear the BVT from previous runs
    bundle; bundle exec rake prepare; # create initial users/assets
    bundle exec rspec # run!

    ./warden_rspec # Run tests in parallel
    ```


## SSH into deployment jobs

To use `bosh ssh` to SSH into running jobs of a deployment, to run the following command:

```
scripts/add-route
```

Now you can now SSH into any VM with `bosh ssh`:

```
$ bosh ssh
1. nats/0
2. syslog_aggregator/0
3. postgres/0
4. uaa/0
5. login/0
6. cloud_controller/0
7. loggregator/0
8. loggregator-router/0
9. health_manager/0
10. dea_next/0
11. router/0
Choose an instance: <your choice>
Enter password (use it to sudo on remote host): vagrant
```

## Restore your deployment

The warden container will lost after vm reboot, but you can restore your deployment with bosh cck.
```
$ bosh cck
```
Chose 2 to recreate each missing vm:
```
Problem 1 of 13: VM with cloud ID `vm-74d58924-7710-4094-86f2-2f38ff47bb9a' missing.
  1. Ignore problem
  2. Recreate VM using last known apply spec
  3. Delete VM reference (DANGEROUS!)
Please choose a resolution [1 - 3]: 2
...
```
Typing yes to confirm at the end:
```
Apply resolutions? (type 'yes' to continue): yes

Applying problem resolutions
  missing_vm 212: Recreate VM using last known apply spec (00:00:13)                                
  missing_vm 215: Recreate VM using last known apply spec (00:00:08)                                
...
Done                    13/13 00:03:48                                                              
```
