# DBs

> **Run db service**

数据库是结构化信息或数据（一般以电子形式存储在计算机系统中）的有组织的集合，通常由数据库管理系统 (`DBMS`) 来控制。在现实中，数据、DBMS 及关联应用一起被称为数据库系统，通常简称为数据库。

为了提高数据处理和查询效率，当今最常见的数据库通常以行和列的形式将数据存储在一系列的表中，支持用户便捷地访问、管理、修改、更新、控制和组织数据。另外，大多数数据库都使用结构化查询语言 (`SQL`) 来编写和查询数据。

![dbs](../../images/composes/linux-dbs-service.png)

## 1. Oracle

> **详情请参考博客[《Oracle 部署和使用》](https://www.escapelife.site/)**

- **oracle-xe-11g**

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder/composes/dbs/oracle/

# 先不要带挂载启动服务
$ docker-compose -f docker-compose-11g.yml up -d

# 复制容器文件到宿主机
$ docker cp oracle_db:/u01/app/oracle/ .
$ mv oracle oracle_db

# 关闭容器挂载之后在启动
$ docker-compose down
$ docker-compose -f docker-compose-11g.yml up -d && docker logs -f oracle_db
```

- **oracle-xe-18c**

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder/composes/dbs/oracle/

# 先不要带挂载启动服务
$ docker-compose -f docker-compose-18c.yml up -d

# 复制容器文件到宿主机(注意赋值证券权限)
$ docker cp oracle_db:/opt/oracle/oradata/ .
$ mv oradata oracle_db

# 关闭容器挂载之后在启动
$ docker-compose down
$ docker-compose -f docker-compose-18c.yml up -d && docker logs -f oracle_db
```

## 2. PostgreSQL

> **详情请参考博客[《PostgreSQL 部署和使用》](https://www.escapelife.site/)**

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder/composes/dbs/postgres/

# 启动服务
$ docker-compose up -d
```

## 3. MySQL

> **详情请参考博客[《MySQL 部署和使用》](https://www.escapelife.site/)**

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder/composes/dbs/mysql/

# 启动服务
$ docker-compose up -d
```

## 4. MariaDB

> **详情请参考博客[《MariaDB 部署和使用》](https://www.escapelife.site/)**

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder/composes/dbs/mariadb/

# 启动服务
$ docker-compose up -d
```

## 5. Redis

> **详情请参考博客[《Redis 部署和使用》](https://www.escapelife.site/)**

```bash
# 下载仓库
$ git clone https://github.com/EscapeLife/awesome-builder.git
$ cd awesome-builder/composes/dbs/redis/

# 启动服务
$ docker-compose up -d
```
