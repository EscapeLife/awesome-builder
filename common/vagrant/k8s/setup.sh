#!/usr/bin/env bash

set -ex

# ubuntu aliyun mirrors
sudo cp /etc/apt/sources.list{,.bak}
sudo cat >/etc/apt/sources.list <<EOF
# apt
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse

# k8s
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main

# docker
deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable
EOF

# kubeadm setting
sudo gpg --keyserver keyserver.ubuntu.com --recv-keys BA07F4FB
sudo gpg --export --armor BA07F4FB | sudo apt-key add -

# docker setting
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

# apt update
sudo apt update
sudo apt dist-upgrade

# install base tools
sudo apt install -y \
    docker-ce docker-ce-cli containerd.io \
    kubeadm ipvsadm \
    ntp ntpdate \
    nginx supervisor

# add user to docker group
sudo usermod -a -G docker $USER

# enable service
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl enable kubelet.service
sudo systemctl start kubelet.service

# close swap
sudo swapoff -a

# set timezone
sudo timedatectl set-timezone Asia/Shanghai

# utc time
sudo timedatectl set-local-rtc 0

# open ipvs
sudo modprobe br_netfilter
sudo cat >/etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv
EOF
sudo chmod 755 /etc/sysconfig/modules/ipvs.modules
sudo bash /etc/sysconfig/modules/ipvs.modules
sudo lsmod | grep -e ip_vs -e nf_conntrack_ipv

# deploy k8s service
if [[ "$HOSTNAME" == "k8s-master" ]]; then
    # kubeadm init
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
    export KUBEADM_TOKEN_GEN
fi

# join to master cluster
if [[ "$HOSTNAME" == "k8s-node1" || "$HOSTNAME" == "k8s-nod2" ]]; then
    # join master
    $(kubeadm token create ${KUBEADM_TOKEN_GEN} --print-join-command --ttl=0)
fi

# deploy flannel and dashboard service
if [[ "$HOSTNAME" == "k8s-master" ]]; then
    # install flannel
    kubectl apply -f /vagrant_data/yaml/kube-flannel.yml

    # install dashboard
    kubectl apply -f /vagrant_data/yaml/kube-dashboard.yml

    # dashboard auth
    kubectl apply -f /vagrant_data/yaml/kube-dashboard-auth.yml

    # supervisor
    cp /vagrant_data/supervisor/k8s.conf /etc/supervisor/conf.d
    sudo supervisorctl update

    # nginx
    cp /vagrant_data/nginx/k8s.conf /etc/nginx/conf.d
    sudo systemctl restart nginx.service
fi
