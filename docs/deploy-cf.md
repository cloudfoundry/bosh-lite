## Deploy Cloud Foundry

* If you are using BOSH Lite with AWS provider edit `manifests/cf-stub-spiff.yml` to include a `domain` key under `properties` that corresponds to a domain you've set up for this Cloud Foundry instance, or if you want to use xip.io, it can be `{your.public.ip}.xip.io`.

* Install [Spiff](https://github.com/cloudfoundry-incubator/spiff). Use the [latest binary of Spiff](https://github.com/cloudfoundry-incubator/spiff/releases), extract it, and make sure that `spiff` is in your `$PATH`. Windows users can perform the Prepare Warden Stemcell and Deploy Cloud Foundry steps within the Ubuntu VM created by Vagrant if no Windows release of Spiff is available, or see [this blog](http://aliwahaj.blogspot.de/2014/01/installing-cloud-foundry-on-vagrant.html) for tips on building Spiff on Windows.

* Clone the [cf-release](https://github.com/cloudfoundry/cf-release) repository into the same directory that you cloned this repository into.

    ```
    cd ~/workspace
    git clone https://github.com/cloudfoundry/cf-release
    cd cf-release
    ./update
    ```

### Single command deploy

Note: This process is an alternative to the manual steps below to deploy the latest version of CloudFoundry.

* Run `./bin/provision_cf` from bosh-lite repository.

### Manual deploy

* Decide which final release of Cloud Foundry you wish to deploy by looking at in the [releases directory of cf-release](https://github.com/cloudfoundry/cf-release/tree/master/releases).  At the time of this writing, cf-214 is the most recent. We will use that as the example, but you are free to substitute any future release.

*  Upload final release

    Use the version that matches the tag you checked out. For v214 you would use: releases/cf-214.yml

    ```
    cd ~/workspace/cf-release
    bosh upload release releases/cf-<version>.yml
    ```

* Upload the Warden stemcell

 A stemcell is a VM template with an embedded BOSH Agent. BOSH Lite uses the Warden CPI, so we need to use the Warden Stemcell which will be the root file system for all Linux Containers created by the Warden CPI.

 Download latest Warden stemcell:

 ```
 curl -L -J -O https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent
 ```

 Upload the stemcell:

 ```
 bosh upload stemcell bosh-warden-boshlite-ubuntu-trusty-go_agent
 ```

 NOTE: It is possible to do this in one command instead of two, but doing this in two steps avoids having to download the stemcell again when you bring up a new BOSH Lite box.

*  Use the `make_manifest_spiff` script to create a cf manifest.  This step assumes you have cf-release checked out in ~/workspace. If you have cf-release checked out to somewhere else, you have to update the `CF_RELEASE_DIR`
 environment variable.  The script also requires that cf-release is checked out with the tag matching the final release you wish to deploy so that the templates used by `make_manifest_spiff` match the code you are deploying.

 `make_manifest_spiff` will target your BOSH Lite Director, find the UUID, create a manifest stub and run spiff to generate a manifest at manifests/cf-manifest.yml. If this fails, try updating Spiff.

 ```
 cd ~/workspace/cf-release
 git checkout <version> # version should be same as the release version you uploaded
 cd ~/workspace/cf-release/bosh-lite
 ./make_manifest
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
# export no_proxy=xip.io,192.168.50.4
cf api --skip-ssl-validation https://api.10.244.0.34.xip.io
cf auth admin admin
cf create-org me
cf target -o me
cf create-space development
cf target -s development
```

Now you are ready to run commands such as `cf push`.
If your Cloud Foundry deployment needs to go through an HTTP proxy to reach the Internet, specify `http_proxy`, `https_proxy` and `no_proxy` environment variables using `cf set-env` or add them to the `env:` section of your application's `manifest.yml`. This ensures the buildpacks can download required libraries, gems, etc. during application staging and running.
