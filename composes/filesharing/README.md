# File Sharing

> **File Sharing Service**

本来是准备将多种服务合并到一起，做一个 `all-in-one` 的容器，但是考虑到时间和精力的问题，还是使用 `hub.docker.com` 上面比较好用的几个容器进行介绍和功能使用说明(其实这个几个容器且很少更新了)，以备后续如果需要使用的话，可以随时拿来使用。

## 1. FTP

> **详情请参考博客[《FTP文件共享服务部署和使用》](https://www.escapelife.site/)**

`FTP` 是一个文件传输的协议，客户端需要使用专门的 `ftp` 客户端与服务器端进行通信，以完成文件的上传和下载，`FTP` 协议工作在应用层。它使用两个连接与客户端通信：**命令连接**用于传输文件管理类命令，此连接在客户端连接后会始终在线；**数据连接**用于传输文件数据，此连接会按序创建。

`FTP` 服务器会监听 `TCP 21` 号端口用于命令连接，而数据连接有两种模式：

- **主动模式**是服务器使用 `TCP 20` 号端口主动创建连接到客户端的某随机端口
- **被动模式**是客户端使用随机端口连接服务器端的随机端口

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder

# 启动方式
$ docker-compose -f ./composes/filesharing/ftp/docker-compose.yml up -d
```

```bash
# 匿名用户

# modified docker-compose file
entrypoint: bash /run.sh -c 30 -C 10 -l puredb:/etc/pure-ftpd/pureftpd.pdb -j -R -P 11.22.33.44 -p 8100:8170

# add ftp user
useradd -d /home/ftp/Anonymous -s /sbin/nologin ftp
```

## 2. NFS

> **详情请参考博客[《NFS文件共享服务部署和使用》](https://www.escapelife.site/)**

`NFS` 全称是 `Network FileSystem，NFS` 和其他文件系统一样，是在 `Linux` 内核中实现的，因此 `NFS` 很难做到与 `Windows` 兼容。`NFS` 共享出的文件系统会被客户端识别为一个文件系统，客户端可以直接挂载并使用。

`NFS` 的实现使用了 `RPC`（`Remote Procedure Call`） 的机制，远程过程调用使得客户端可以调用服务端的函数。由于有 `VFS` 的存在，客户端可以像使用其他普通文件系统一样使用 `NFS` 文件系统，由操作系统内核将 `NFS` 文件系统的调用请求通过 `TCP/IP` 发送至服务端的 `NFS` 服务，执行相关的操作，之后服务端再讲操作结果返回客户端。

NFS 文件系统仅支持基于 `IP` 的用户访问控制，`NFS` 是在内核实现的，因此 `NFS` 服务由内核监听在 `TCP` 和 `UDP` 的 `2049` 端口，对于 `NFS` 服务的支持需要在内核编译时选择。它同时还使用了几个用户空间进程用于访问控制，用户映射等服务，这些程序由 `nfs-utils` 程序包提供。`RPC` 服务在 `CentOS 6.5` 之后改名为 `portmapper`，它监听在 `TCP/UDP` 的 `111` 端口，其他基于 `RPC` 的服务进程需要监听时，先像 `RPC` 服务注册，`RPC` 服务为其分配一个随机。

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder

# 启动方式
$ docker-compose -f ./composes/filesharing/nfs/docker-compose.yml up -d
```

## 3. Samba

> **详情请参考博客[《Samba文件共享服务部署和使用》](https://www.escapelife.site/)**

`NFS` 只能在 `Unix` 系统间进行共享，而 `Windows` 对其支持很有限。因此有人就在 `Linux/Unix` 系统中实现了 `Windows` 文件共享所使用的 `CIFS` 协议，也叫做 `SMB`（`Simple Message Block`）协议。这使得 `Windows/Linux/Unix` 间可以自由的进行文件共享。`samba` 主要监听在这几个端口：`137/udp`, `138/udp`, `139/tcp`, `445/tcp`。在 `Windows` 中共享的文件系统，可以在 `Linux` 中使用 `samba` 客户端访问，或者直接挂载访问。

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder

# 启动方式
$ docker-compose -f ./composes/filesharing/samba/docker-compose.yml up -d
```

## 4. Nginx

> **详情请参考博客[《Nginx文件共享服务部署和使用》](https://www.escapelife.site/)**

使用 `Nginx` 搭建一个文件共享服务也是可以实现的，同样也可以加密码和用户名。

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder

# 启动方式
$ docker-compose -f ./composes/filesharing/nginx/docker-compose.yml up -d
```

## 5. IIS

> **详情请参考博客[《IIS文件共享服务部署和使用》](https://www.escapelife.site/)**

`IIS` 是一种 `Web`(网页)服务组件，其中包括 `Web` 服务器、`FTP` 服务器、`NNTP` 服务器和 `SMTP` 服务器，分别用于网页浏览、文件传输、新闻服务和邮件发送等方面，它使得在网络(包括互联网和局域网)上发布信息成了一件很容易的事。

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder

# 启动方式
$ docker-compose -f ./composes/filesharing/iis/docker-compose.yml up -d
```
