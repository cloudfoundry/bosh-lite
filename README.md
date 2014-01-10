# bosh-lite

A local development environment for BOSH using warden containers in a vagrant box.

This readme walks through deploying Cloud Foundry with bosh-lite.  Bosh and bosh-lite can be used to deploy just about anything once you've got the hang of it.

## Installation

For all use cases, first prepare this project with `bundler` .

1. Install [vagrant](http://www.vagrantup.com/downloads.html)

    Known working version:

    ```
    $ vagrant -v
    Vagrant 1.4.2
    ```

1. Install Ruby + RubyGems + Bundler

1. Run Bundler from the base directory of this repository

    ```
    bundle
    ```


Below are installation insructions for different Vagrant providers.

* VMWare Fusion
* Virtualbox
* AWS


### Using the VMWare Fusion Provider (preferred)

Fusion is faster, more reliable and we test against it more frequently. Both fusion and the vagrant fusion provider require a license.

Known to work with Fusion version 6.0.2 and vagrant plugin vagrant-vmware-fusion version 2.2.0.

**Note**: Although it appears you can bring a vagrant box up without having the Fusion app running, be aware that quitting the Fusion app will suspend your VM. 

1. Install vagrant Fusion Plugin and license

    This requires a license file for Fusion. If you don't have one visit http://www.vagrantup.com to purchase
a license. 

    ```
    vagrant plugin install --plugin-version 2.2.0 vagrant-vmware-fusion
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

### Using the Virtualbox Provider


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

### Using the AWS Provider

1. Install Vagrant AWS provider

    ```
    vagrant plugin install vagrant-aws
    ```

    Known to work for version: vagrant-aws 0.4.0

1. Add dummy AWS box

    ```
    vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
    ```

1. Set environment variables called `BOSH_AWS_ACCESS_KEY_ID` and `BOSH_AWS_SECRET_ACCESS_KEY` with the appropriate values.  If you've followed along with other documentation such as [these steps to deploy Cloud Foundry on AWS](http://docs.cloudfoundry.com/docs/running/deploying-cf/ec2/index.html#deployment-env-prep), you may simply need to source your `bosh_environment` file.
1. Make sure the EC2 security group you are using in the `Vagrantfile` exists and allows inbound TCP traffic on ports 25555 (for the BOSH director), 22 (for SSH), 80/443 (for Cloud Controller), and 4443 (for Loggregator).
1. Run Vagrant from the `aws` folder:

    ```
    cd aws
    vagrant up --provider=aws
    cd ..
    ```

1. Bosh target (login with admin/admin)

    ```
    bosh target <IP of the box>
    Target set to `Bosh Lite Director'
    Your username: admin
    Enter password: admin
    Logged in as `admin'
    ```

1. Edit manifests/cf-stub-spiff.yml to include a 'domain' key under 'properties' that corresponds to a domain you've set up for this Cloud Foundry instance, or if you want to use xip.io, it can be {your.public.ip}.xip.io.

1. Direct future traffic received on the instance to another ip (the HAProxy):

```
sudo iptables -t nat -A PREROUTING -p tcp -d <internal IP of instance> --dport 80 -j DNAT --to 10.244.0.34:80
sudo iptables -t nat -A PREROUTING -p tcp -d <internal IP of instance> --dport 443 -j DNAT --to 10.244.0.34:443
sudo iptables -t nat -A PREROUTING -p tcp -d <internal IP of instance> --dport 4443 -j DNAT --to 10.244.0.34:4443
```

These rules are cleared on restart. They can be saved and configured to be reloaded on startup if so desired (granted the internal ip remains the same).


## Upload Warden stemcell

bosh-lite uses the Warden CPI, so we need to use the Warden Stemcell which will be the root file system for all Linux Containers created by the Warden CPI.

1. Download latest warden stemcell

    ```
    wget http://bosh-jenkins-gems-warden.s3.amazonaws.com/stemcells/latest-bosh-stemcell-warden.tgz
    ```

1. Upload the stemcell

    ```
    bosh upload stemcell latest-bosh-stemcell-warden.tgz
    ```

NB: It is possible to do this in one command instead of two, but doing this in two steps avoids having to download the stemcell again when you bring up a new bosh-lite box.

Note: You can also use 'bosh public stemcells' to list and download the latest warden stemcell

example:
```
$ bosh public stemcells 
+---------------------------------------------+
| Name                                        |
+---------------------------------------------+
| bosh-stemcell-1722-aws-xen-ubuntu.tgz       |
| bosh-stemcell-1722-aws-xen-centos.tgz       |
| light-bosh-stemcell-1722-aws-xen-ubuntu.tgz |
| light-bosh-stemcell-1722-aws-xen-centos.tgz |
| bosh-stemcell-1722-openstack-kvm-ubuntu.tgz |
| bosh-stemcell-1722-vsphere-esxi-ubuntu.tgz  |
| bosh-stemcell-1722-vsphere-esxi-centos.tgz  |
| bosh-stemcell-24-warden-boshlite-ubuntu.tgz |
+---------------------------------------------+

$ bosh download public stemcell bosh-stemcell-24-warden-boshlite-ubuntu.tgz
```

## Deploy Cloud Foundry


1.  Install [spiff](https://github.com/cloudfoundry-incubator/spiff).
    ```
    # command from http://spiff.cfapps.io

    curl -s http://spiff.cfapps.io/install.sh | bash
    ```
    **Note**: consider whether you have an older version of spiff in your path; replace the older version with the newer. 
    ```
    $ mv spiff /usr/local/bin/
    ```

1. Decide which final release of Cloud Foundry you wish to deploy, by looking at in the [releases directory of cf-release](https://github.com/cloudfoundry/cf-release/tree/master/releases).  At the time of this writing, cf-149 is the most recent.  We will use that as the example, but you are free to substitute any future release.

1. Check out the desired revision of cf-release, (eg, 149)

    ````
    cd ~/workspace/cf-release
    ./update
    git checkout v149
    ````

1.  Use the make_manifest_spiff script to create a cf manifest.  This step assumes you have cf-release checked out to ~/workspace.  It requires that cf-release is checked out the tag matching the final release you wish to deploy so tha the templates used by make_manifest_spiff match the code you are deploying.

    make_manifest_spiff will target your bosh-lite director, find the uuid, create a manifest stub and run spiff to generate a manifest at manifests/cf-manifest.yml. (If this fails, try updating spiff)

    ```
    cd ~/workspace/bosh-lite
    ./scripts/make_manifest_spiff
    ```

1.  Upload final release

    ```
    cd ~/workspace/cf-release
    bosh upload release releases/cf-149.yml
    ```

1.  Deploy CF to bosh-lite

    ```
    cd ~/workspace/bosh-lite
    bosh deployment manifests/cf-manifest.yml
    bosh deploy
    # enter yes to confirm
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

    b.  Run yeti as normal from cf-release/src/tests.. e.g. (Make sure you are logged in via cf before running these commands)

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
Choose an instance:
```

## Restore your deployment

The warden container will be lost after vm reboot, but you can restore your deployment with bosh cck, bosh's command for recovering from unepexted errors.
```
$ bosh cck
```
Choose `2` to recreate each missing vm:
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

## Troubleshooting

1. Starting over again is often the quickest path to success, you can use `vagrant destroy` from the base directory of this project to remove the VM.
1. To start with a new VM just execute the appropriate `vagrant up` command optionally with the provider option as shown in the earlier sections.

## Manage your local boxes

We publish pre-built Vagrant boxes on Amazon S3. It is recommened to use the latest boxes.

### Download latest boxes

Just get a latest copy of the Vagrantfile from this repo and run `vagrant up`.

### Delete old boxes

Free some disk space by deleting the old boxes.

    $ vagrant box list
    boshlite-ubuntu1204-build55 (virtualbox)
    boshlite-ubuntu1204-build55 (vmware_desktop)
    boshlite-ubuntu1204-build74 (virtualbox)
    boshlite-ubuntu1204-build83 (virtualbox)

    $ vagrant box remove boshlite-ubuntu1204-build55 virtualbox
    Removing box 'boshlite-ubuntu1204-build55' with provider 'virtualbox'...


