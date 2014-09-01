# BOSH Lite

A local development environment for BOSH using warden containers in a Vagrant box.

This readme walks through deploying Cloud Foundry with BOSH Lite.
Bosh and BOSH Lite can be used to deploy just about anything once you've got the hang of it.

## Install

### Prepare the Environment

1. Install latest version of `bosh_cli`.

   ```
   gem install bosh_cli
   ```

1. Install [Spiff](https://github.com/cloudfoundry-incubator/spiff). Use the [latest binary of Spiff](https://github.com/cloudfoundry-incubator/spiff/releases), extract it, and make sure that `spiff` is in your `$PATH`. Windows users can perform the Prepare Warden Stemcell and Deploy Cloud Foundry steps within the Ubuntu VM created by Vagrant if no Windows release of Spiff is available, or see [this blog](http://aliwahaj.blogspot.de/2014/01/installing-cloud-foundry-on-vagrant.html) for tips on building Spiff on Windows.

1. Install [Vagrant](http://www.vagrantup.com/downloads.html).

    Known working version:

    ```
    $ vagrant --version
    Vagrant 1.6.3
    ```

1. Clone this repository.

### Install and Boot a Virtual Machine

Below are installation instructions for different Vagrant providers.

* Virtualbox
* VMware Fusion
* AWS

#### Using the Virtualbox Provider

1. Install Virtualbox

    Known working version:

    ```
    $ VBoxManage --version
    4.3.14r95030
    ```

1. Start Vagrant from the base directory of this repository. This uses the Vagrantfile.

    ```
    vagrant up --provider=virtualbox
    ```

1. Target the BOSH Director and login with admin/admin.

    ```
    # if behind a proxy, exclude this IP by setting no_proxy (xip.io is introduced later)
    $ export no_proxy=192.168.50.4,xip.io
    $ bosh target 192.168.50.4 lite
    Target set to `Bosh Lite Director'
    $ bosh login
    Your username: admin
    Enter password: *****
    Logged in as `admin'
    ```

1. Add a set of route entries to your local route table to enable direct Warden container access every time your networking gets reset (e.g. reboot or connect to a different network). Your sudo password may be required.

    ```
    bin/add-route
    ```

#### Using the VMware Fusion Provider

VMware boxes are not currently published and will need to be built locally.

1. Install licensed VMware Fusion

    Known working version:

    ```
    $ vmware-vmx -v

    VMware Fusion Information:
    VMware Fusion 6.0.4 build-1887983 Release
    ```

1. Install licensed vagrant-vmware-fusion plugin

    Known working version:

    ```
    $ vagrant plugin list | grep vmware-fusion

    vagrant-vmware-fusion (2.5.2)
    ```

1. Start Vagrant from the base directory of this repository. This uses the Vagrantfile.

    ```
    vagrant up --provider=vmware_fusion
    ```

1. Target the BOSH Director and login with admin/admin.

    ```
    $ bosh target 192.168.50.4 lite
    Target set to `Bosh Lite Director'
    $ bosh login
    Your username: admin
    Enter password: *****
    Logged in as `admin'
    ```

1. Add a set of route entries to your local route table to enable direct Warden container access every time your networking gets reset (e.g. reboot or connect to a different network). Your sudo password may be required.

    ```
    bin/add-route
    ```

#### Using the AWS Provider

##### EC2 Classic or VPC

The default mode provisions the BOSH-lite VM in EC2 classic. If you set the `BOSH_LITE_SUBNET_ID` environment
variable, vagrant will provision the BOSH Lite VM in that subnet in whichever VPC it lives.

When deploying to a VPC, the security group must be specified as an ID of the form `sg-abcd1234`, as
opposed to a name like `default`.

NOTE: You can only deploy into a VPC if the instance can be accessed by the machine doing the deploying. If
not, Vagrant will fail to use SSH to provision the instance further. This similarly applies to steps 7-9, below.

##### Steps

* Install Vagrant AWS provider

    ```
    vagrant plugin install vagrant-aws
    ```

    Known working version: 0.4.1

* Set environment variables called `BOSH_AWS_ACCESS_KEY_ID` and `BOSH_AWS_SECRET_ACCESS_KEY` with the appropriate values. If you've followed along with other documentation such as [these steps to deploy Cloud Foundry on AWS](http://docs.cloudfoundry.org/deploying/ec2/bootstrap-aws-vpc.html), you may simply need to source your `bosh_environment` file.

AWS Environment Variables:

|Name|Description|Default|
|---|---|---|
|BOSH_AWS_ACCESS_KEY_ID         |AWS access key ID                    | |
|BOSH_AWS_SECRET_ACCESS_KEY     |AWS secret access key                | |
|BOSH_LITE_KEYPAIR              |AWS keypair name                     |bosh|
|BOSH_LITE_NAME                 |AWS instance name                    |Vagrant|
|BOSH_LITE_SECURITY_GROUP       |AWS security group                   |inception|
|BOSH_LITE_PRIVATE_KEY          |path to private key matching keypair |~/.ssh/id_rsa_bosh|
|[VPC only] BOSH_LITE_SUBNET_ID |AWS VPC subnet ID                    | |

* Make sure the EC2 security group you are using in the `Vagrantfile` exists and allows inbound TCP traffic on ports 25555 (for the BOSH director), 22 (for SSH), 80/443 (for Cloud Controller), and 4443 (for Loggregator).

* Run vagrant up with provider `aws`:

    ```
    vagrant up --provider=aws
    ```

* Find out the public IP of the box you just launched. You can see this info at the end of `vagrant up` output. Another way is running `vagrant ssh-config remote`.


* Target the BOSH Director and login with admin/admin.

    ```
    $ bosh target <public_ip_of_the_box>
    Target set to `Bosh Lite Director'
    $ bosh login
    Your username: admin
    Enter password: *****
    Logged in as `admin'
    ```

* As part of vagrant provisioning bosh-lite is setting IP tables rules to direct future traffic received on the instance to another ip (the HAProxy). These rules are cleared on restart.
In case of restart they can be created by running `vagrant provision remote`.

## Deploy Cloud Foundry

1. Edit manifests/cf-stub-spiff.yml to include a 'domain' key under 'properties' that corresponds to a domain you've set up for this Cloud Foundry instance, or if you want to use xip.io, it can be {your.public.ip}.xip.io.

### Single command deploy

Alternatively to the steps below, you can also run this script to deploy the latest version of CloudFoundry:

```
$ ./bin/provision_cf
```

### Manual deploy

*  Install [Spiff](https://github.com/cloudfoundry-incubator/spiff). Use the [latest binary of Spiff](https://github.com/cloudfoundry-incubator/spiff/releases), extract it, and make sure that `spiff` is in your `$PATH`.

* Clone a copy of cf-release:
    ```
    cd ~/workspace
    git clone https://github.com/cloudfoundry/cf-release
    ```

* Decide which final release of Cloud Foundry you wish to deploy by looking at in the [releases directory of cf-release](https://github.com/cloudfoundry/cf-release/tree/master/releases).  At the time of this writing, cf-180 is the most recent. We will use that as the example, but you are free to substitute any future release.

*  Upload final release

    Use the version that matches the tag you checked out. For v180 you would use: releases/cf-180.yml

    ```
    cd ~/workspace/cf-release
    bosh upload release releases/cf-<version>.yml
    ```

* Upload the Warden stemcell

 A stemcell is a VM template with an embedded BOSH Agent. BOSH Lite uses the Warden CPI, so we need to use the Warden Stemcell which will be the root file system for all Linux Containers created by the Warden CPI.

 Download latest Warden stemcell:

 ```
 wget http://bosh-jenkins-artifacts.s3.amazonaws.com/bosh-stemcell/warden/latest-bosh-stemcell-warden.tgz
 ```

 Upload the stemcell:

 ```
 bosh upload stemcell latest-bosh-stemcell-warden.tgz
 ```

 NOTE: It is possible to do this in one command instead of two, but doing this in two steps avoids having to download the stemcell again when you bring up a new BOSH Lite box.

 You can also use 'bosh public stemcells' to list and download the latest Warden stemcell

 Example (the versions you see will be different from these):

 ```
$ bosh public stemcells
+-------------------------------------------------------------+
| Name                                                        |
+-------------------------------------------------------------+
| ...                                                         |
| bosh-stemcell-21-warden-boshlite-ubuntu-trusty-go_agent.tgz |
| bosh-stemcell-53-warden-boshlite-ubuntu.tgz                 |
| bosh-stemcell-64-warden-boshlite-ubuntu-lucid-go_agent.tgz  |
| ...                                                         |
+-------------------------------------------------------------+

 $ bosh download public stemcell bosh-stemcell-21-warden-boshlite-ubuntu-trusty-go_agent.tgz
```

*  Use the `make_manifest_spiff` script to create a cf manifest.  This step assumes you have cf-release checked out in ~/workspace. If you have cf-release checked out to somewhere else, you have to update the `CF_RELEASE_DIR`
 environment variable.  The script also requires that cf-release is checked out with the tag matching the final release you wish to deploy so that the templates used by `make_manifest_spiff` match the code you are deploying.

 `make_manifest_spiff` will target your BOSH Lite Director, find the UUID, create a manifest stub and run spiff to generate a manifest at manifests/cf-manifest.yml. If this fails, try updating Spiff.

 ```
 cd ~/workspace/bosh-lite
 ./bin/make_manifest_spiff
 ```

 If you want to change the jobs properties for this bosh-lite deployment, e.g. number of nats servers, you can change it in the template located under cf-release/templates/cf-infrastructure-warden.yml.


*  Deploy CF to bosh-lite

    ```
    bosh deployment manifests/cf-manifest.yml # This will be done for you by make_manifest_spiff
    bosh deploy
    # enter yes to confirm
    ```

* Run the [cf-acceptance-tests](https://github.com/cloudfoundry/cf-acceptance-tests) against your new deployment to make sure it's working correctly.

 Install [Go](http://golang.org/) version 1.2.1 64-bit and setup the Go environment:

 ```
 mkdir -p ~/go
 export GOPATH=~/go
 ```
 Download the cf-acceptance-tests repository:

 ```
 go get github.com/cloudfoundry/cf-acceptance-tests ...
 cd $GOPATH/src/github.com/cloudfoundry/cf-acceptance-tests
 ```
 Follow the [cats](https://github.com/cloudfoundry/cf-acceptance-tests) instructions on Running the tests.


## Try your Cloud Foundry deployment

Install the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli) and run the following:

```
# for AWS use public IP https://api.BOSH_LITE_PUBLIC_IP.xip.io
# else, and if behind a proxy, exclude this domain by setting no_proxy
# export no_proxy=192.168.50.4,xip.io
cf api --skip-ssl-validation https://api.10.244.0.34.xip.io
cf auth admin admin
cf create-org me
cf target -o me
cf create-space development
cf target -s development
```
Now you are ready to run commands such as `cf push`.
If your Cloud Foundry deployment needs to go through an HTTP proxy to reach the Internet, specify `http_proxy`, `https_proxy` and `no_proxy` environment variables using `cf create-env` or add them to the `env:` section of your application's `manifest.yaml`. This ensures the buildpacks can download required libraries, gems, etc. during application staging and running.


## SSH into deployment jobs

Use `bosh ssh` to SSH into running jobs of a deployment.

### For local providers:

Run the following command:

```
bin/add-route
```

Now you can SSH into any VM with `bosh ssh`:

```
$ bosh ssh
1. ha_proxy_z1/0
2. nats_z1/0
3. etcd_z1/0
4. postgres_z1/0
5. uaa_z1/0
6. login_z1/0
7. api_z1/0
8. hm9000_z1/0
9. runner_z1/0
10. loggregator_z1/0
11. loggregator_trafficcontroller_z1/0
12. router_z1/0
13. acceptance_tests/0
14. acceptance_tests_diego/0
15. smoke_tests/0
Choose an instance:
```

Note: `bosh shh` automatically finds and uses the first key from your ssh keychain. If you do not have any RSA keys, you must create one. In a unix environment, this can be accomplished using `ssh-keygen`. You can then and add it to your keychain or you can pass the public key file to the command `bosh ssh --public_key /path/of/public/key`.

### For AWS provider:

SSH into any VM with `bosh ssh` providing `--gateway_identity_file, --gateway_host and --gateway_user`

```
$  bosh ssh --gateway_identity_file=~/.ssh/id_rsa_bosh  --gateway_host=AWS_IP --gateway_user=ubuntu
1. ha_proxy_z1/0
2. nats_z1/0
3. etcd_z1/0
4. postgres_z1/0
5. uaa_z1/0
6. login_z1/0
7. api_z1/0
8. hm9000_z1/0
9. runner_z1/0
10. loggregator_z1/0
11. loggregator_trafficcontroller_z1/0
12. router_z1/0
13. acceptance_tests/0
14. acceptance_tests_diego/0
15. smoke_tests/0
Choose an instance:
```

## Restore your deployment

The Warden container will be lost after a vm reboot, but you can restore your deployment with `bosh cck`, BOSH's command for recovering from unexpected errors.
```
$ bosh cck
```

Choose `2` to recreate each missing VM:
```
Problem 1 of 13: VM with cloud ID `vm-74d58924-7710-4094-86f2-2f38ff47bb9a' missing.
  1. Ignore problem
  2. Recreate VM using last known apply spec
  3. Delete VM reference (DANGEROUS!)
Please choose a resolution [1 - 3]: 2
...
```
Type yes to confirm at the end:
```
Apply resolutions? (type 'yes' to continue): yes

Applying problem resolutions
  missing_vm 212: Recreate VM using last known apply spec (00:00:13)
  missing_vm 215: Recreate VM using last known apply spec (00:00:08)
...
Done                    13/13 00:03:48
```

## Troubleshooting

1. Starting over again is often the quickest path to success; you can use `vagrant destroy` from the base directory of this project to remove the VM.
1. To start with a new VM, just execute the appropriate `vagrant up` command, optionally passing in the provider as shown in the earlier sections.

## Manage your local boxes

We publish pre-built Vagrant boxes on Amazon S3. It is recommended to use the latest boxes.

### Download latest boxes

Just get a latest copy of the Vagrantfile from this repo and run `vagrant up`.

## Working offline

See the [offline documentation](docs/offline_dns.md)
