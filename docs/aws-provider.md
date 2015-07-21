## Using the AWS Provider

### EC2 Classic or VPC

The default mode provisions the BOSH-lite VM in EC2 classic. If you set the `BOSH_LITE_SUBNET_ID` environment
variable, vagrant will provision the BOSH Lite VM in that subnet in whichever VPC it lives.

When deploying to a VPC, the security group must be specified as an ID of the form `sg-abcd1234`, as
opposed to a name like `default`.

Note: You can only deploy into a VPC if the instance can be accessed by the machine doing the deploying. If
not, Vagrant will fail to use SSH to provision the instance further. This similarly applies to steps 7-9, below.

### Steps

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
|BOSH_AWS_REGION                |AWS availability zone                |us-east-1|
|[VPC only] BOSH_LITE_SUBNET_ID |AWS VPC subnet ID                    | |

* **NOTE**: `BOSH_LITE_SECURITY_GROUP` should be set to group id not the group name if VM is deployed into the VPC, e.g. `sg-11764446`

* Make sure the EC2 security group you are using in the `Vagrantfile` exists and allows inbound TCP traffic on ports 25555 (for the BOSH director), 22 (for SSH), 80/443 (for Cloud Controller), and 4443 (for Loggregator).

* Run vagrant up with provider `aws`:

    ```
    vagrant up --provider=aws
    ```

* Find out the public IP of the box you just launched. You can see this info at the end of `vagrant up` output. Another way is running `vagrant ssh-config`.

* Target the BOSH Director and login with admin/admin.

    ```
    $ bosh target <public_ip_of_the_box>
    Target set to `Bosh Lite Director'
    $ bosh login
    Your username: admin
    Enter password: *****
    Logged in as `admin'
    ```

* As part of vagrant provisioning bosh-lite is setting IP tables rules to direct future traffic received on the instance to another ip (the HAProxy). These rules are cleared on restart. In case of restart they can be created by running `vagrant provision`.

### Customizing AWS provisioning

The AWS bosh-lite VM will echo its private IP on provisioning so that you can target it. You can disable this by uncommenting the `public_ip` provisioner in the `aws` provider.

```
  config.vm.provider :aws do |v, override|
    # To turn off public IP echoing, uncomment this lines:
    # override.vm.provision :shell, id: "public_ip", run: "always", inline: "/bin/true"
  end
```

Port forwarding on HTTP/S ports is set up for the CF Cloud Controller on the AWS VM. If you are not going to deploy Cloud Contorller (or just don't want this), you can disable this by uncommenting the `port_forwarding` provisioner in the `aws` provider.

```
  config.vm.provider :aws do |v, override|
    # To turn off CF port forwarding, uncomment this line:
    # override.vm.provision :shell, id: "port_forwarding", run: "always", inline: "/bin/true"
  end
```
