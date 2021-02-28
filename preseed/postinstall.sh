#!/bin/sh
apt install -y etckeeper
sed -i 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf

sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="compose:menu"/' /etc/default/keyboard

apt install -y openssh-server
sed -i 's/Port 22/Port 12345/' /etc/ssh/sshd_config
echo PasswordAuthentication no >> /etc/ssh/sshd_config

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

sudo -u ubuntu mkdir ~ubuntu/.ssh
sudo -u ubuntu install -m 600 /dev/null ~ubuntu/.ssh/authorized_keys
# https://gist.github.com/baztian/68bc33c3552d602d27e87bf23df219c8
for i in desktop mobilePhone samsungTablet; do
    wget -O - https://gist.githubusercontent.com/baztian/68bc33c3552d602d27e87bf23df219c8/raw/id_rsa.pub.$i >> ~ubuntu/.ssh/authorized_keys
done

sudo -u ubuntu mkdir ~ubuntu/Sources
sudo -u ubuntu git clone https://github.com/baztian/ansible-mint-setup.git ~ubuntu/Sources/ansible-mint-setup

usermod -md /home/bbowe -c "Bastian Bowe" -l bbowe ubuntu
groupmod -n bbowe ubuntu
etckeeper commit "renamed ubuntu user"
