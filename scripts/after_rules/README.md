# After Rules

> **解决UFW无法管理Docker发布出来的端口问题**

## 1. 规则添加方式

```bash
# route
$ ufw route allow proto tcp from any to any port 80
$ ufw route allow proto tcp from any to 172.17.0.2 port 80
$ ufw route allow proto udp from any to any port 53
$ ufw route allow proto udp from any to 172.17.0.2 port 53
$ ufw route allow proto udp from any port 53 to any port 1024:65535
```

## 2. 工具使用介绍

- 显示帮助

```bash
ufw-docker help
```

- 检查 UFW 配置文件中防火墙规则的安装

```bash
ufw-docker check
```

- 更新 UFW 的配置文件，添加必要的防火墙规则

```bash
ufw-docker install
```

- 显示当前防火墙允许的转发规则

```bash
ufw-docker status
```

- 列出所有和容器 httpd 相关的防火墙规则

```bash
ufw-docker list httpd
```

- 暴露容器 httpd 的 80 端口

```bash
ufw-docker allow httpd 80
```

- 暴露容器 httpd 的 443 端口，且协议为 tcp

```bash
ufw-docker allow httpd 443/tcp
```

- 把容器 httpd 的所有映射端口都暴露出来

```bash
ufw-docker allow httpd
```

- 删除所有和容器 httpd 相关的防火墙规则

```bash
ufw-docker delete allow httpd
```

- 删除容器 httpd 的 tcp 端口 443 的规则

```bash
ufw-docker delete allow httpd 443/tcp
```

- 暴露服务 web 的 80 端口

```bash
# docker service create --name web 8080:80 httpd:alpine
ufw-docker service allow web 80
ufw-docker service allow web 80/tcp
```

- 删除与服务 web 相关的规则

```bash
ufw-docker service delete allow web
```
