# Using the AWS Provider

## Prerequisites

1. Install Vagrant AWS provider

    ```
    $ vagrant plugin install vagrant-aws
    ```

    Known working version: 0.4.1

1. If you don't already have one, create an AWS Access Key. Set environment variables `BOSH_AWS_ACCESS_KEY_ID` and `BOSH_AWS_SECRET_ACCESS_KEY`.
1. Create an SSH key pair so that you can SSH into Bosh Lite once it is deployed. If you generate an EC2 Key Pair in AWS the private key will be downloaded. Call the EC2 Key Pair `bosh` or set the environment variable `BOSH_LITE_KEYPAIR` to the name you gave. Set `BOSH_LITE_PRIVATE_KEY` to the local file path for the private key (defaults to `~/.ssh/id_rsa_bosh`). 

To configure these environment variables all at once, copy and paste the following script into your shell then edit the file `aws-boshlite` to add values. 
```
cat > aws-boshlite <<EOF
export BOSH_AWS_ACCESS_KEY_ID=
export BOSH_AWS_SECRET_ACCESS_KEY=
export BOSH_LITE_PRIVATE_KEY=
EOF
```
Now set the environment variables by sourcing the file:
```
source aws-boshlite
```
### Additional Prerequisites for EC2 Classic

1. Create a Security Group with name `inception`, or set the environment variable `BOSH_LITE_SECURITY_GROUP` to the Group Name of the security group you created. Group ID will not be recognized unless the Security Group is associated with a VPC.
1. Continue to [Deploy BOSH Lite](#deploy-bosh-lite).

### Additional Prerequisites for VPC

1. If you don't already have one, create a VPC. If you use the VPC Wizard, a Security Group and a Subnet will be created for you. If you create the VPC manually a Security Group will be created automatically but you must manually create a Subnet.
1. Set the environment variable `BOSH_LITE_SECURITY_GROUP` to the Group ID (e.g. `sg-62166d1a`) of a Security Group associated with the VPC. Note: this is different from EC2-Classic, where the Group Name is used.
1. By default Security Groups only allow access from within the Security Group. Modify the Security Group to allow inbound traffic from anywhere (set Source to `0.0.0.0/0`). 
  - If you want to lock down access, BOSH Lite requires inbound traffic on ports 25555 (for the BOSH director), 22 (for SSH), 80/443 (for Cloud Controller), and 4443 (for Loggregator).
1. If you don't already have one, create a Subnet. Set the environment variable `BOSH_LITE_SUBNET_ID` to the Subnet ID (e.g. `subnet-37d0526f`).
1. By default, VMs will not be assigned a public IP on creation. Modify the Subnet to Enable auto-assign Public IP.
1. Continue to [Deploy BOSH Lite](#deploy-bosh-lite).

### Supported Environment Variables

The full list of supported environment variables follows:

|Name|Description|Default|
|---|---|---|
|BOSH_AWS_ACCESS_KEY_ID     |AWS Access Key ID                    | |
|BOSH_AWS_SECRET_ACCESS_KEY |AWS Secret Access Key                | |
|BOSH_LITE_KEYPAIR          |AWS EC2 Key Pair name                |bosh|
|BOSH_LITE_PRIVATE_KEY      |Local file path for private key matching `BOSH_LITE_KEYPAIR` |~/.ssh/id_rsa_bosh|
|BOSH_LITE_SECURITY_GROUP   |AWS Security Group ID (Use the ID, not the name; e.g. `sg-62166d1a`) |inception|
|BOSH_LITE_SUBNET_ID        |AWS VPC Subnet ID (Not necessary for EC2 Classic. Use the ID, not the name; e.g. `subnet-37d0526f`) | |
|BOSH_LITE_NAME             |AWS EC2 instance name                |Vagrant|

## Deploy BOSH Lite

1. Run vagrant up with provider `aws`:

    ```
    $ vagrant up --provider=aws
    ```

1. If you haven't already, install the BOSH CLI

  See [bosh.io](http://bosh.io/docs/bosh-cli.html) for instructions.
  
1. Target the BOSH Director and login

  - Use the public IP found in the output of `vagrant up` or the hostname returned by running `vagrant ssh-config` 
  - Default credentials are admin/admin

    ```
    $ bosh target <public_ip_of_the_box>
    Target set to `Bosh Lite Director'

    $ bosh login
    Your username: admin
    Enter password: *****
    Logged in as `admin'
    ```

## Troubleshooting

- As part of Vagrant provisioning bosh-lite is setting IP tables rules to direct future traffic received on the instance to another IP (the HAProxy). These rules are cleared on restart. In case of restart they can be created by running `vagrant provision`.

## Customizing AWS Provisioning

The following instructions involve modifying the Vagrantfile found in the cloned bosh-lite directory.

- The AWS bosh-lite VM will echo its private IP on provisioning so that you can target it. You can disable this by uncommenting the `public_ip` provisioner in the `aws` provider.

    ```
    config.vm.provider :aws do |v, override|
      override.vm.provision :shell, id: "public_ip", run: "always", inline: "/bin/true"
    end
    ```

- Port forwarding on HTTP/S ports is set up for the CF Cloud Controller on the AWS VM. If you are not going to deploy Cloud Contorller (or just don't want this), you can disable this by uncommenting the `port_forwarding` provisioner in the `aws` provider.

    ```
    config.vm.provider :aws do |v, override|
      override.vm.provision :shell, id: "port_forwarding", run: "always", inline: "/bin/true"
    end
    ```

- AWS boxes are published for the following regions: us-east-1, us-west-1, us-west-2, eu-west-1, ap-southeast-1, ap-southeast-2, ap-northeast-1, sa-east-1. Default region is us-east-1. To use a different region add `region` configuration to the `aws` provider.

    ```
    config.vm.provider :aws do |v, override|
      v.region = "us-west-2"
    end
    ```
