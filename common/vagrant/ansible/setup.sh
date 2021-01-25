#/bin/sh

set -ex

# install some tools
sudo yum install -y epel-release git vim gcc glibc-static telnet

# open password auth for backup if ssh key doesn't work, bydefault, username=vagrant password=vagrant
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# install ansible
if [ "$HOSTNAME" = "ansible-master" ]; then
    sudo yum install -y ansible
fi
