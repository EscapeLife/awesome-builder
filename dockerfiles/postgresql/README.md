# PostgreSQL DB

> **完美的PG数据库，从这里开始！**

![PostgreSQL DB](../../images/dockerfiles/linux-postgres-tool.png)

## 0. 章节目录

- [1.容器的基本使用](https://github.com/EscapeLife/awesome-builder/blob/master/dockerfiles/postgresql/README.md#1-%E5%AE%B9%E5%99%A8%E7%9A%84%E5%9F%BA%E6%9C%AC%E4%BD%BF%E7%94%A8)
- [2.增量恢复和重建](https://github.com/EscapeLife/awesome-builder/blob/master/dockerfiles/postgresql/README.md#3-%E5%A2%9E%E9%87%8F%E6%81%A2%E5%A4%8D%E5%92%8C%E9%87%8D%E5%BB%BA)
- [3.功能示例的说明](https://github.com/EscapeLife/awesome-builder/blob/master/dockerfiles/postgresql/README.md#4-%E5%8A%9F%E8%83%BD%E7%A4%BA%E4%BE%8B%E7%9A%84%E8%AF%B4%E6%98%8E)

## 1. 容器的基本使用

> **主要介绍postgres_es容器的基本使用方式和方法**

- **build**

```bash
# base image
$ docker pull postgres:10

# build postgres_es image
$ cd dockerfiles/postgresql
$ docker build --squash --no-cache --tag=postgres_es:latest .
```

- **docker**

```bash
# docker run postgres_es
docker run -d --name=postgres_es \
    -v ./postgres:/data \
    -p 5432:5432 \
    -e POSTGRES_DB=app \
    -e POSTGRES_PASSWORD=123456 \
    --network=postgres_es_network \
    postgres_es:latest
```

- **compose**

```yaml
# postgres_es compose yml
version: "3.7"

services:
  postgres:
    restart: on-failure
    container_name: postgres_es
    image: postgres_es:latest
    volumes:
      - "./postgres:/data"
    environment:
      - DEBUG=false
      - POSTGRES_DB=app
      - POSTGRES_PASSWORD=123456
    networks:
      - postgres_es_network

networks:
  postgres_es_network:
```

## 2. 增量恢复和重建

> **数据库 WAL 增量方式的数据恢复和数据重建**
>
> - **WAL 恢复只支持单机模式**
> - **WAL 重建只支持单机模式**

- **环境变量说明**

| 参数编号 | 参数名称               | 含义说明        |
| ------ | ---------------------- | ------------------------------------------------- |
| 1      | `RECOVERY_TARGET_TIME` | 配置格式如`2020-02-07 17:27:08 UTC`所示即可，需要注意的是容器内时区为`UTC` |
| 2      | `SKIP_BACKUP`          | 当该字段被设定时，会自动跳过备份，备份数据存放在 `/data/backup_xxxxxxxx` 目录内 |

### 2.1 增量 WAL 恢复数据

```bash
# PG服务暂停并执行如下操作(默认恢复到最新事件)
$ docker run -it --entrypoint=pg_wal_recovery.sh postgres_es:latest

# 恢复数据
$ docker exec -it -e RECOVERY_TARGET_TIME='2020-02-07 17:27:08' <postgres_pd_id> pg_wal_recovery.sh

# 重新启动数据库
$ docker run or docker-compose
```

### 2.2 增量 WAL 重建数据

```bash
# 重建数据
$ docker exec -it postgres_pd pg_wal_rebase.sh
```

## 3. 功能示例的说明

> **主要介绍新增的功能和启动、使用方式**

- **常用参数**

| 参数名称                              | 含义说明                                   |
| ------------------------------------- | ------------------------------------------ |
| `POSTGRES_MAX_CONNECTIONS`            | 最大连接数，默认 `1000`                    |
| `POSTGRES_MAX_WAL_SIZE`               | 最大 `WAL` 缓存大小，默认 `16` (M)           |
| `POSTGRES_LOG_MIN_DURATION_STATEMENT` | 记录超过该时间的查询日志，默认 `3000` (ms) |
| `DISABLE_WAL_BACKUP`                  | 是否启用 `WAL` 备份机制                    |

- **示例说明**

```bash
# 可以运行为non-root模式
# 需要-v的目录"owner uid"和启动传的"owner uid"一致
docker run -d --name=postgres_es \
    -v ./postgres:/data \
    -p 5432:5432 \
    -e POSTGRES_DB=app \
    -e POSTGRES_PASSWORD=123456 \
    -u 10086:10086 \
    --network=postgres_es_network \
    postgres_es:latest
```
