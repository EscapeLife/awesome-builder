# Watchtower

> **Docker更新容器镜像神器**

![Watchtower](../../images/composes/linux-watchtower-service.png)

---

[Watchtower](https://github.com/containrrr/watchtower) 是一个可以实现自动化更新 Docker 基础镜像与容器的实用工具。它监视正在运行的容器以及相关的镜像，当检测到 reg­istry 中的镜像与本地的镜像有差异时，它会拉取最新镜像并使用最初部署时相同的参数重新启动相应的容器，一切好像什么都没发生过，就像更新手机上的 App 一样。

```bash
# [常用参数]
1. 默认监控本地Docker守护进程运行的所有容器 => nginx/redis
2. 不作为守护进程运行并在执行之后移除瞭望塔容器 => --run-once
3. 设置容器更新的上游检测更新时间而默认值为300s => --interval 30s
4. 可以指向远程Docker主机进行监控 => --host tcp://10.0.1.2:2375
5. 设置定时任务来定时更新远程镜像 => --schedule "0 0 4 * * *"
6. 在容器更新时发送通知 => --notifications [email|slack|msteams|gotify]

# [了解参数]
--cleanup: 删除更新后的旧图像
--debug: 使用详细日志记录启用调试模式
--monitor-only: 只监视新镜像而不更新容器
--stop-timeout: 容器被强制停止之前超时(默认10秒)
--tlsverify: 连接Docker套接字时使用TLS证书进行验证
```

```yaml
version: "3"

services:
  watchtower:
    restart: on-failure
    container_name: watchtower
    image: containrrr/watchtower
    volumes:
      # - /root/.docker/config.json:/config.json
      - /var/run/docker.sock:/var/run/docker.sock
      - $DOCKER_CERT_PATH:/etc/ssl/docker
    environment:
      - REPO_USER=username
      - REPO_PASS=password
      - DOCKER_HOST="tcp://10.0.1.2:2375"
      - DOCKER_CERT_PATH=/etc/ssl/docker
    command: --run-once --interval 30 nginx redis
    networks:
      - watchtower_network

networks:
  watchtower_network:
```
