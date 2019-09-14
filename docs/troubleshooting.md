# Troubleshooting

## cf CLI returns server error

```
$ cf api --skip-ssl-validation https://api.10.244.0.34.xip.io
Setting api endpoint to https://api.10.244.0.34.xip.io...
FAILED
Server error, status code: XXX, error code: 0, message: ...
```

This is a CloudFoundry specific error. Please file an issue on [cf-release repo](https://github.com/cloudfoundry/cf-release).

## bosh ssh times out connecting to VMs

```
Starting interactive shell on job public_haproxy_z1/0
ssh: connect to host 10.244.50.2 port 22: Connection timed out
```

This error happens when 10.244.x.x IP addresses are not accessbile from your machine. Confirm that you can ping 10.244.50.2. If it's not pingable make sure to run `bin/add-route` from bosh-lite directory to set up proper routing to 10.244.x.x IPs.

Related issue: <https://github.com/cloudfoundry/bosh-lite/issues/296>

## None of the deployed components are accessible after reboot

See [bosh cck documentation](bosh-cck.md) for restoring deployments after VM reboot.

## Inaccessible Director

```
$ bosh target 192.168.50.4 lite
[WARNING] cannot access director, trying 4 more times...
[WARNING] cannot access director, trying 3 more times...
[WARNING] cannot access director, trying 2 more times...
[WARNING] cannot access director, trying 1 more times...
cannot access director (execution expired)
```

Make sure that `192.168.50.1` is pingable. If it's not pingable, it is most likely that your VirtualBox installation did not properly set up networking. Rebooting the machine that runs VirtualBox typically resolves this problem.

## Inaccessible Director with SSL errors

Your machine is pingable, but you see this

```
$ bosh target 192.168.50.4 lite
RSA 1024 bit CA certificates are loaded due to old openssl compatibility
[WARNING] cannot access director, trying 4 more times...
[WARNING] cannot access director, trying 3 more times...
[WARNING] cannot access director, trying 2 more times...
[WARNING] cannot access director, trying 1 more times...
cannot access director (SSL_connect returned=1 errno=0 state=SSLv2/v3 read server hello A: sslv3 alert handshake failure)
```

The problem most probably is related to the ruby version. Please upgrade to a recent version and try again.

## Network already acquired

```
Error 100: Creating VM with agent ID 'cfd86507-0dec-417f-b19f-5d87806bf783': Creating container: network already acquired: 10.244.9.16/30
```

This error happens when VMs (really containers) managed by Garden are left around from a previous deploy. Typically this is due using `--force` flag on `bosh delete deployment` command. Easiest way to resolve this problem is to run `vagrant reload` which will restart the bosh-lite VM and clear up any state.

Related issue: <https://github.com/cloudfoundry/bosh-lite/issues/311>

## Customization command failed

```
A customization command failed:
["modifyvm", :id, "--paravirtprovider", "minimal"]
```

Please upgrade to VirtualBox 5+. We are now using 'paravirtprovider=minimal' mode to avoid kernel CPU lockups.

## "An error occurred while downloading the remote file. The error message, if any, is reproduced below. Please fix this error and try again."

There is an issue (discussed [here](https://groups.google.com/a/cloudfoundry.org/forum/m/#!topic/bosh-users/n2qYrpPUJaE) and [here](https://github.com/mitchellh/vagrant/issues/3589)) with Vagrant permissions running on OS X Mavericks 10.9.2+ (after applying [Apple's Security Update 2014-002](http://support.apple.com/en-us/HT202966)). To diagnose, run `vagrant up --debug` and see if there is an error mentioning `Symbol not found: _iconv`. To resolve try one of the following:

	1. Upgrade Vagrant to the latest version
	2. Purge Vagrant, purge ~/.vagrant.d, and reinstall Vagrant
	3. Removing code block as described [here](https://github.com/mitchellh/vagrant/issues/3589#issuecomment-42255427)

## "The guest machine entered an invalid state"

```
$ vagrant up
...

The guest machine entered an invalid state while waiting for it
to boot. Valid states are 'starting, running'. The machine is in the
'poweroff' state. Please verify everything is configured
properly and try again.

If the provider you're using has a GUI that comes with it,
it is often helpful to open that and watch the machine, since the
GUI often has more helpful error messages than Vagrant can retrieve.
For example, if you're using VirtualBox, run vagrant up while the
VirtualBox GUI is open.
```

This typically means that your VirtualBox installation is not configured properly. Before trying bosh-lite box, please verify that you can use Vagrant with a default box for Ubuntu.
