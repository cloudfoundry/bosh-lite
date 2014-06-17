Templates and scripts are based on <https://github.com/misheska/basebox-packer>

# Prerequisites for building Vagrant boxes

1. Install Ruby + RubyGems + Bundler

1. Run Bundler from the base directory of this repository

```shell
bundle
```

1. Run Librarian

```shell
librarian-chef install
```

1. Download and install Packer from <http://www.packer.io/docs/installation.html>

# Automatically Building the Vagrant boxes

A GNU Make makefile is provided to support automated builds.  It assumes that GNU Make is in the PATH.

To build all boxes:

```shell
cd boxes
make
```

Or, to build one box:

```shell
cd boxes
make list
# Choose a definition, like 'virtualbox/boshlite-ubuntu1204.box'
make virtualbox/boshlite-ubuntu1204.box
```

# Other templates

There are other templates that are not currently built automatically for
release. To build one of the other templates: 

```shell
cd boxes/template/boshlite-ubuntu1204
rm -rf output-vmware-iso
mkdir -p ../../vmware
packer build -only=vmware-iso -var-file=second-instance-variables.json template.json
```
