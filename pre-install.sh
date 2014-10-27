#!/bin/bash

# Configure sourcelist
sudo sh -c "echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/juno main > /etc/apt/sources.list.d/ubuntu-cloud-archive-juno-trusty.list"

# update
sudo apt-get update

# Install python software properties
sudo apt-get -y install python-software-properties

# Install ubuntu cloud keyring
sudo apt-get -y install ubuntu-cloud-keyring

# update
sudo apt-get update
