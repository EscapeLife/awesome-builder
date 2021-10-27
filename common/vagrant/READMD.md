# 欢迎来到 Vagrant 的乐园

> **折腾关于 Vagrant 服务配置以及测试/实验的快速搭建**

`Vagrant` 是一款用于构建及配置虚拟开发环境的软件，基于 `Ruby`, 主要以命令行的方式运行。主要使用 `Oracle` 的开源 `VirtualBox` 虚拟化系统，与 `Chef`，`Salt`，`Puppet` 等环境配置管理软件搭配使用， 可以实行快速虚拟开发环境的构建。

![欢迎来到Vagrant的乐园](../../images/common/welcome-to-vagrant.jpg)

---

## 1. 目录对应功能

> **介绍每个目录下面的 Vagrant 到底是为了那方面的测试呢！**

| 编号 | 目录名称  | 对应功能                              |
| ---- | --------- | ------------------------------------- |
| 1    | `ansible` | 学习 Ansible 工具的测试环境(三台机器) |
| 2    | `docker`  | 通过 Vagrant 直接启动 docker 服务     |
| 3    | `k8s`     | 学习 K8S 平台的实验测试环境(三台机器) |
| 4    | `single`  | 平时快速测试或者实验的单机操作系统    |

---

## 2. K8S

> **介绍 K8S 实验环境的使用方式！**

- **[1] 一键安装 - Ubuntu18.04**

```bash
# 启动
$ vagrant up
```

- **[2] 三台机器的 IP 地址**

```bash
机器名      IP
master     192.168.30.30
node1      192.168.30.31
node2      192.168.30.32
```

- **[3] kubeadm 配置**

```bash
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- **[4] 集群状态和使用**

```bash
# 查询集群状态
$ kubectl cluster-info

# 查看服务状态
$ kubectl get node,po,svc -A -owide
```

- **[5] 其他服务安装**

```bash
# 可以按需下载对应yml文件，然后通过如下命令部署服务
$ kubectl apply -f metrics.yaml
$ kubectl apply -f https://addons.kuboard.cn/kuboard/kuboard-v3.yaml
```

---

## 3. Ansible

> **介绍 Ansible 实验环境的使用方式！**

- **[1] 一键安装 - Ubuntu18.04**

```bash
# 启动
$ vagrant up
```

- **[2] 三台机器的 IP 地址**

```bash
机器名      IP
master     192.168.200.10
node1      192.168.200.11
node2      192.168.200.12
```

---

## 4. 优秀项目推进

> **推荐使用 Vagrant 相关比较好的项目和仓库！**

- [Vagrant 一键安装 Kubernetes 集群](https://github.com/ameizi/vagrant-kubernetes-cluster)
