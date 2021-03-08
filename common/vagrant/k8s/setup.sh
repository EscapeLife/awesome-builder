#!/usr/bin/env bash

set -ex

# ubuntu aliyun mirrors
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
cat >./sources.list <<EOF
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
deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu bionic stable
EOF
sudo mv ./sources.list /etc/apt/

# kubeadm setting
sudo gpg --keyserver keyserver.ubuntu.com --recv-keys BA07F4FB
sudo gpg --export --armor BA07F4FB | sudo apt-key add -

# docker setting
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

# add user to docker group
sudo usermod -a -G docker $USER
newgrp docker

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

# deploy k8s service
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

# deploy flannel and dashboard service
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
