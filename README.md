## Vagrant Setup

This tutorial guides you through creating your K8s VM lab.

We start with a generic Ubuntu VM, and use bash script to:
* install packages for git, golang, ...   
* create user accounts, and add ssh publish key
* config host name  
* config static ip

Afterwards, we'll see how easy it is to package our newly provisioned VM
environment into a new "Vagrant box", which can be instantly deployed for new
projects, and shared with others.


## Install Vagrant

For a backgrond on Vagrant, see:
* http://vagrantup.com/v1/docs/getting-started/index.html
* http://vagrantup.com/v1/docs/provisioners/chef_solo.html

Download and install VirtualBox from https://www.virtualbox.org/wiki/Downloads
Download and install Vagrant from http://downloads.vagrantup.com

## Start vm
```bash 
cd single_node/setup_vm 
    vagrant up
``` 

## Destroy vm
```bash 
cd single_node/setup_vm 
    vagrant destroy
```

## Mount file to vm
```ruby
  config.vm.synced_folder "#{vagrant_root}/../..", "/home/#{USER_NAME}", disabled: false
```