#!/usr/bin/env bash

set -ex

echo ">>> [TASK 1] Setting TimeZone ..."
sudo timedatectl set-timezone Asia/Shanghai
sudo timedatectl set-local-rtc 0

echo ">>> [TASK 2] Setting DNS ..."
cat >./resolved.conf <<EOF
[Resolve]
DNS=114.114.114.114
FallbackDNS=223.5.5.5
EOF
sudo mv ./resolved.conf /etc/systemd/
sudo systemctl daemon-reload
sudo systemctl restart systemd-resolved.service
sudo mv /etc/resolv.conf /etc/resolv.conf.bak
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

echo ">>> [TASK 3]  Aliyun Ubuntu Mirrors ..."
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
cat >./sources.list <<EOF
# apt
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse

# k8s
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main

# docker
deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu bionic stable
EOF
sudo mv ./sources.list /etc/apt/

echo ">>> [TASK 4] Setting Kubeadm ..."
sudo gpg --keyserver keyserver.ubuntu.com --recv-keys BA07F4FB
sudo gpg --export --armor BA07F4FB | sudo apt-key add -

echo ">>> [TASK 5] Setting Docker ..."
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# apt update
sudo apt update
sudo apt dist-upgrade -y

# install base tools
sudo apt install -y \
    docker-ce \
    kubeadm ipvsadm \
    ntp ntpdate \
    nginx supervisor

echo ">>> [TASK 6] Add User To Docker Group ..."
sudo usermod -a -G docker $USER
newgrp docker

# enable service
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl enable kubelet.service
sudo systemctl start kubelet.service

echo ">>> [TASK 7] Disable And Close SWAP ..."
sudo swapoff -a

echo ">>> [TASK 8] Enable and Load Kernel modules"
scat >>./containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo mv ./containerd.conf /etc/modules-load.d/
sudo modprobe overlay
sudo modprobe br_netfilter

echo ">>> [TASK 9] Add Kernel Settings ..."
cat >>./kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo mv ./kubernetes.conf /etc/sysctl.d/
sudo sysctl --system >/dev/null 2>&1

echo ">>> [TASK 10] Enable ssh password authentication"
sudo sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo echo 'PermitRootLogin yes' >>/etc/ssh/sshd_config
sudo systemctl reload sshd

echo ">>> [TASK 11] Set root password"
echo -e "kubeadmin\nkubeadmin" | sudo passwd root >/dev/null 2>&1
sudo echo "export TERM=xterm" >>/etc/bash.bashrc

echo ">>> [TASK 12] Deploy K8S Service ..."
if [[ "$HOSTNAME" == "k8s-master" ]]; then
    # kubeadm init
    echo "###### the ${HOSTNAME} init cluster ######"
    sudo kubeadm init \
        --kubernetes-version=1.20.2 \
        --image-repository registry.aliyuncs.com/google_containers \
        --apiserver-advertise-address=192.168.30.30 \
        --pod-network-cidr=10.244.0.0/16 \
        --service-cidr=10.245.0.0/16

    # setting master config
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    source <(kubectl completion bash)

    # get token
    KUBEADM_TOKEN_GEN=$(kubeadm token generate)
    KUBEADM_JOIN_COMMAND=$(kubeadm token create ${KUBEADM_TOKEN_GEN} --print-join-command --ttl=0)

    # token to nodex
    mkdir -pv /vagrant_data/tmp/
    echo "sudo ${KUBEADM_JOIN_COMMAND}" >/vagrant_data/tmp/KUBEADM_JOIN_COMMAND.txt
fi

# join to master cluster
if [[ "$HOSTNAME" == "k8s-node1" || "$HOSTNAME" == "k8s-node2" ]]; then
    # join master
    echo "###### the ${HOSTNAME} join master ######"
    $(cat /vagrant_data/tmp/KUBEADM_JOIN_COMMAND.txt)
fi

echo ">>> [TASK 12] Deploy Flannel And Dashboard Service ..."
if [[ "$HOSTNAME" == "k8s-master" ]]; then
    # install flannel
    echo "###### deploy flannel yaml ######"
    kubectl apply -f /vagrant_data/yaml/kube-flannel.yml

    # install dashboard
    echo "###### deploy dashboard yaml ######"
    kubectl apply -f /vagrant_data/yaml/kube-dashboard.yml

    # dashboard auth
    echo "###### deploy dashboard auth yaml ######"
    kubectl apply -f /vagrant_data/yaml/kube-dashboard-auth.yml

    # supervisor
    echo "###### run nginx service ######"
    sudo cp /vagrant_data/supervisor/k8s.conf /etc/supervisor/conf.d
    sudo supervisorctl update

    # nginx
    echo "###### run nginx service ######"
    sudo cp /vagrant_data/nginx/k8s.conf /etc/nginx/conf.d
    sudo systemctl restart nginx.service

    # dashborad token
    echo "###### create dashborad token ######"
    kubectl -n kubernetes-dashboard describe secret \
        $(kubectl -n kubernetes-dashboard get secret | \grep admin-user | awk '{print $1}') \
        >/vagrant_data/tmp/KUBEADM_DASHBOARD_TOKEN.txt
fi
