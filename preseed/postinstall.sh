#!/bin/sh
sed -i 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf

sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="compose:menu"/' /etc/default/keyboard

apt install -y openssh-server
sed -i 's/Port 22/Port 12345/' /etc/ssh/sshd_config
apt-get -y install git
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible
cat > /etc/ansible/ansible.cfg <<HERE

[defaults]
interpreter_python = /usr/bin/python3
nocows = 1
HERE
