Templates and scripts are based on https://github.com/misheska/basebox-packer

##Build the boxes

A GNU Make makefile is provided to support automated builds.  It assumes
that both GNU Make and Packer are in the PATH.  Download and install
Packer from <http://www.packer.io/downloads.html>


To build all boxes:

    make

Or, to build one box:

    make list

    # Choose a definition, like 'virtualbox/boshlite-ubuntu1204.box'
    make virtualbox/boshlite-ubuntu1204.box
##Launch bosh-lite boxes

Use the Vagrantfile in this folder

    vagrant up [--provider=vmware_fusion]
