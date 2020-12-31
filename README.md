# puppet-desktop

Puppet module for configuring a Linux desktop  

Tested with Ubuntu 20.04

This module installs the following software:

Shell Utilities
* Powerline status bar
* ssh-agent script
* tmux

Editors
* Vim and plugins
* Atom and plugins
* Ansible
* Fabric

Software Development
* Python and pip
* Node.js
* Go
* Java

DevOps Tools
* awscli and aws-env scripts
* Openstack client
* Terraform
* Docker

Desktop Applications
* i3 window manager
* Xfce window manager
* lilyterm random background script
* xrdp
* Google Chrome/Chromium
* FireFox
* PasswordSafe
* Keepassx
* MPlayer
* PulseAudio

Prereqs

Install Puppet

sudo su -
apt-get install puppet

puppet module install puppetlabs-stdlib
puppet module install puppetlabs-vcsrepo

git clone this repo 
