# Cloudreve网盘工具使用说明

> **关于工具的详细使用和攻略可以参考参考地址中的官方文档和github仓库**

![Cloudreve使用说明](../../images/dockerfiles/linux-cloudreve-tool.png)

## 1. 快速构建

- 根据系统架构的不同，在 [`GitHub Release`](https://github.com/cloudreve/Cloudreve/releases) 页面获取已经构建打包完成的主程序压缩包，对其进行解压替换 `source` 目录中的主程序压缩包(该版本为3.0.0 RC-1，可能比较旧了)，然后通过本项目的 `Dockerfile` 文件进行本地打包，构建 `docker` 镜像包。

```bash
# 本地打包镜像
$ docker build --squash --no-cache --tag=cloudreve:0.0.1 .
```

## 2. 开始使用

- `Cloudreve` 在首次启动时，会创建初始管理员账号和密码，请注意保管好管理员的密码，此密码只会在首次启动时出现。在本项目中，其会出现在映射出来的 `./cloudreve/logs/cloudreve-stdout.log` 文件中。果您忘记初始管理员密码，则需要删除数据库，重新启动主程序以初始化新的管理员账户。
- 本项目已经修改了 `Cloudreve` 工具的默认的服务的配置文件，设置默认会监听在 `80` 端口。之后，可以通过单独启动或者使用 `docker-compose.yml` 文件启动服务，就可以在浏览器中访问 `http://服务器IP:80` 进入了。

```bash
# 单独启动启动(数据库使用SQLite)
# ./cloudreve/logs: 用于保存服务的相关日志
# ./cloudreve/uploads: 用于保存上传到网盘的文件
# ./cloudreve/db: 用于报错SQLite数据库
$ docker run -d -p 80:80 --name cloudreve \
    -e TZ="Asia/Shanghai" \
    -v ./cloudreve/logs:/data/logs \
    -v ./cloudreve/uploads:/data/uploads \
    -v ./cloudreve/db:/data/cloudreve.db \
    cloudreve:0.0.1
```

```bash
# 使用docker-compose启动服务(数据库使用MySQL和Redis)
# ./cloudreve/logs: 用于保存服务的相关日志
# ./cloudreve/uploads: 用于保存上传到网盘的文件
$ docker-compose -f ./docker/compose/http/docker-compose.yml up -d

# 添加了对HTTPS协议的支持(需要先生成证书)
$ docker-compose -f ./docker/compose/https/docker-compose.yml up -d
```

## 3. 补充说明

- 在自用或者小规模使用的场景下，完全可以使用 `Cloudreve` 内置的 `Web` 服务器。但是如果你需要使用 `HTTPS` 的话，亦或是需要与服务器上其他 `Web` 服务共存时，你可能需要使用主流 `Web` 服务器反向代理 `Cloudreve`，以获得更丰富的扩展功能。
- 本项目默认构建的容器并没有让 `Nginx` 服务直接支持 `HTTPS` 协议，但是在 `docker/nginx` 目录下存放了关于使用 `HTTPS` 协议的相关配置。如果需要使用的话，直接将 `https.conf` 文件里面的内容覆盖 `cloudreve.conf` 文件，同时还需要将自己的证书文件放置在 `docker/letsencrypt` 目录下，即可开始编译。注意访问的地址就需要变成 `https://服务器IP:443` 了。

```bash
# 使用certbot工具生成的证书
# 关于证书的生成可以参考: https://www.escapelife.site/posts/16b3fd32.html
$ tree example.com
example.com
├── chain1.pem
├── fullchain1.pem
└── privkey1.pem
```

## 4. 参考地址

- [官方Github仓库](https://github.com/cloudreve/Cloudreve)
- [官方使用文档地址](https://docs.cloudreve.org/)
