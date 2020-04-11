# Wizserver

> **为知笔记: 私有部署 Docker 镜像，我们来了！**

![Wizserver](../../images/composes/linux-wiz-service.png)

---

您可以直接使用 Docker 运行为知笔记服务端，不需要有任何 IT 知识。为知笔记私有部署 Docker 镜像，包含有完整的为知笔记服务端以及所需的各种环境，同时还包含了为知笔记网页版。您只需要启用为知笔记服务端，就可以利用自带的为知笔记网页版，在局域网内无限制使用为知笔记各种功能了。

```yaml
version: "3"

services:
  watchtower:
    restart: on-failure
    container_name: wizserver
    image: wiznote/wizserver
    ports:
      - "80:80"
      - "9269:9269/udp"
    volumes:
      - "wizserver_data:/wiz/storage"
    environment:
      - TZ='Asia/Shanghai'
    networks:
      - wizserver_network

volumes:
  wizserver_data:

networks:
  wizserver_network:
```
