# Using the AWS Provider

These instructions assume use of AWS VPC.

## Prerequisites

1. Install Vagrant AWS provider

    ```
    $ vagrant plugin install vagrant-aws
    ```

    Known working version: 0.4.1

1. If you don't already have one, create an SSH key pair so that you can access Bosh Lite once it is deployed. By default, Vagrant will look for this in `~/.ssh/id_rsa_bosh`. To specify a different location, provide the full path with environment variable `BOSH_LITE_PRIVATE_KEY`.
1. If you don't already have one, create an AWS Access Key. Set environment variables `BOSH_AWS_ACCESS_KEY_ID` and `BOSH_AWS_SECRET_ACCESS_KEY`.
1. If you don't already have one, create a VPC, subnet and security group. If you use the VPC Wizard, these will be created for you all at once. Set environment variables `BOSH_LITE_SUBNET_ID` and `BOSH_LITE_SECURITY_GROUP`. 
  - Use the IDs as values for these environment variables, not the names, e.g `subnet-37d0526f` and `sg-62166d1a`.
  - Make sure the security group is associated with the VPC and allows inbound TCP traffic on ports 25555 (for the BOSH director), 22 (for SSH), 80/443 (for Cloud Controller), and 4443 (for Loggregator).
  - If you do not specify a Subnet ID, Vagrant will look for one called `inception`.
1. Create an EC2 Key Pair, or upload one of your own.
  - By default, Vagrant will look for a keypair in the `bosh-lite` directory called `bosh`. If you use AWS to create a Key Pair and call it `bosh`, it will be downloaded as `bosh.pem`. Move it to the `bosh-lite` directory. 
1. The AWS EC2 instance will be named `Vagrant` by default. To change this use the environment variable `BOSH_LITE_NAME`.

To configure the necessary environment variables all at once, copy and paste the following script into your shell then edit the file `aws-boshlite` to add the necessary values. This assumes your SSH key and AWS Key Pair are in the default locations. If they are not, add them to the file.

```
cat > aws-boshlite <<EOF
export BOSH_AWS_ACCESS_KEY_ID=
export BOSH_AWS_SECRET_ACCESS_KEY=
export BOSH_LITE_SECURITY_GROUP=
export BOSH_LITE_SUBNET_ID=
EOF
```
Now set the environment variables:
```
source aws-boshlite
```

The full list of supported environment variables follows:

|Name|Description|Default|
|---|---|---|
|BOSH_LITE_PRIVATE_KEY      |path to private key matching keypair |~/.ssh/id_rsa_bosh|
|BOSH_AWS_ACCESS_KEY_ID     |AWS Access Key ID                    | |
|BOSH_AWS_SECRET_ACCESS_KEY |AWS Secret Access Key                | |
|BOSH_LITE_SECURITY_GROUP   |AWS Security Group (Use the ID not the name; e.g. `sg-62166d1a`) |inception|
|BOSH_LITE_SUBNET_ID        |AWS VPC Subnet ID (Not necessary for EC2 Classic. Use the ID not the name; e.g. `subnet-37d0526f`) | |
|BOSH_LITE_KEYPAIR          |AWS Key Pair name                    |bosh|
|BOSH_LITE_NAME             |AWS EC2 instance name                |Vagrant|

## Deploy Bosh Lite

1. Run vagrant up with provider `aws`:

    ```
    $ vagrant up --provider=aws
    ```

1. Find out the public IP of the box you just launched. You can see this info at the end of `vagrant up` output. Another way is running `vagrant ssh-config`.

1. Target the BOSH Director and login with admin/admin.

    ```
    $ bosh target <public_ip_of_the_box>
    Target set to `Bosh Lite Director'

    $ bosh login
    Your username: admin
    Enter password: *****
    Logged in as `admin'
    ```

1. As part of Vagrant provisioning bosh-lite is setting IP tables rules to direct future traffic received on the instance to another IP (the HAProxy). These rules are cleared on restart. In case of restart they can be created by running `vagrant provision`.

### Customizing AWS provisioning

The AWS bosh-lite VM will echo its private IP on provisioning so that you can target it. You can disable this by uncommenting the `public_ip` provisioner in the `aws` provider.

```
config.vm.provider :aws do |v, override|
  override.vm.provision :shell, id: "public_ip", run: "always", inline: "/bin/true"
end
```

Port forwarding on HTTP/S ports is set up for the CF Cloud Controller on the AWS VM. If you are not going to deploy Cloud Contorller (or just don't want this), you can disable this by uncommenting the `port_forwarding` provisioner in the `aws` provider.

```
config.vm.provider :aws do |v, override|
  override.vm.provision :shell, id: "port_forwarding", run: "always", inline: "/bin/true"
end
```

AWS boxes are published for the following regions: us-east-1, us-west-1, us-west-2, eu-west-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1. Default region is us-east-1. To use a different region add `region` configuration to the `aws` provider.

```
config.vm.provider :aws do |v, override|
  v.region = "us-west-2"
end
```

### EC2 Classic or VPC

The default mode provisions the BOSH-lite VM in EC2 classic. If you set the `BOSH_LITE_SUBNET_ID` environment variable, vagrant will provision the BOSH Lite VM in that subnet in whichever VPC it lives.

Note: You can only deploy into a VPC if the instance can be accessed by the machine doing the deploying. If not, Vagrant will fail to use SSH to provision the instance further.
