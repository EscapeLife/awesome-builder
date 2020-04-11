# Portainer

> **一个轻量级的Docker环境管理UI**

![Portainer](../../images/composes/linux-portainer-service.png)

---

[Portainer](https://portainer.readthedocs.io/en/stable/index.html) 是一个轻量级的 Docker 环境管理 UI 服务，可以用来管理 Docker 宿主机和 Docker Swarm 集群非常好用且方便。它十分轻量级，轻量到只要个不到 100M 的 Docker 镜像容器就可以完整的提供服务。

Portainer 是 Docker 的图形化管理工具，提供状态显示面板、应用模板快速部署、容器镜像网络数据卷的基本操作（包括上传下载镜像，创建容器等操作）、事件日志显示、容器控制台操作、Swarm 集群和服务等集中管理和操作、登录用户管理和控制等功能。功能十分全面，基本能满足个人用户对容器管理的全部需求。

```bash
# --admin-password: 设置管理用户的登录密码
# -H/--host: Docker守护进程的endpoint
# --logo: 设置前端UI中显示的徽标图片URL地址
```

```yaml
version: "3"

services:
  portainer:
    restart: on-failure
    container_name: portainer
    image: portainer/portainer
    ports:
      - "9000:9000"
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    command: -H unix:///var/run/docker.sock --admin-password=123456
    networks:
      - portainer_network

volumes:
  portainer_data:

networks:
  portainer_network:
```
