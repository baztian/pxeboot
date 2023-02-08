#!/bin/sh
extract_param()
{
    PARAM_NAME=$1
    grep -o "$PARAM_NAME"'=[^ ]*' /proc/cmdline|cut -f2- -d=
}
apt install -y etckeeper

HOST_NAME=$(extract_param hostname)
if [ -n "$HOST_NAME" ]; then
    hostnamectl set-hostname "$HOST_NAME"
    # hostnamectl during setup doesn't seem to work. Therefore:
    sed -i "s/ubuntu/$HOST_NAME/" /etc/hostname
    sed -i "s/ubuntu/$HOST_NAME/" /etc/hosts
    etckeeper commit "renamed ubuntu hostname to $HOST_NAME"
fi

sed -i 's/^managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf
etckeeper commit "NetworkManager managed=true"

sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="compose:menu"/' /etc/default/keyboard
etckeeper commit "Set compose key to menu key"

apt install -y openssh-server
SSH_PORT=$(extract_param ssh-port)
if [ -n "$SSH_PORT" ]; then
    echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
fi
echo PasswordAuthentication no >> /etc/ssh/sshd_config
etckeeper commit "Set up ssh server"

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
apt install -y jq
# https://gist.github.com/baztian/68bc33c3552d602d27e87bf23df219c8
curl  -H "Accept: application/vnd.github.v3+json" https://api.github.com/gists/68bc33c3552d602d27e87bf23df219c8 | \
    python3 -c 'import json,sys;obj=json.load(sys.stdin);files=obj["files"];print("".join(files[i]["content"] for i in files))' \
        >> ~ubuntu/.ssh/authorized_keys

sudo -u ubuntu mkdir ~ubuntu/Sources
sudo -u ubuntu git clone https://github.com/baztian/ansible-mint-setup.git ~ubuntu/Sources/ansible-mint-setup

USER_LANG=$(extract_param user-lang)
if [ -n "$USER_LANG" ]; then
    # Example value: de_DE.utf8
    echo "export LANGUAGE=$USER_LANG" >> ~ubuntu/.profile
fi

USER_NAME=$(extract_param username)
if [ -n "$USER_NAME" ]; then
    usermod -md "/home/$USER_NAME" -c "$USER_NAME" -l "$USER_NAME" ubuntu
    groupmod -n "$USER_NAME" ubuntu
    etckeeper commit "renamed ubuntu user to $USER_NAME"
else
    USER_NAME=ubuntu
fi

AUTO_LOGIN=$(extract_param auto-login)
if [ "$AUTO_LOGIN" = "true" ]; then
    # https://unix.stackexchange.com/questions/381785/how-do-i-enable-auto-login-in-mint-18
    test -d /etc/lightdm && cat << HERE > /etc/lightdm/lightdm.conf
[Seat:*]
autologin-user=$USER_NAME
HERE
    etckeeper commit "autologin user $USER_NAME"
fi