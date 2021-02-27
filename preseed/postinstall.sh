#!/bin/sh
apt install -y etckeeper
sed -i 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf

sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="compose:menu"/' /etc/default/keyboard

apt install -y openssh-server
sed -i 's/Port 22/Port 12345/' /etc/ssh/sshd_config

apt install -y git
apt-add-repository -y ppa:ansible/ansible
apt update
apt install -y ansible
cat > /etc/ansible/ansible.cfg <<HERE

[defaults]
interpreter_python = /usr/bin/python3
nocows = 1
HERE
etckeeper commit "ansible configuration"
chmod 751 ~ubuntu
