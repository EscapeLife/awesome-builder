# PostgREST

> **使用Haskell语言编写的Postgres数据库REST风格的API接口服务**

![PostgREST](../../images/composes/linux-postgrest-service.png)

---

## 1. 项目介绍

使用 [PostgREST](https://github.com/PostgREST/postgrest) 服务的话，我们可以节省对于 PostgreSQL 数据库接口开发。我们不再需要从零开始编写，其自身就提供的 API 接口，则完全符合 REST风格，而且更加纯粹和高效I，数据库中的结构约束和权限决定 API 端点和操作。

PostgREST 是一个独立的 Web 服务器，它将 PostgreSQL 数据库完美的转换为 RESTful API。而且 PostgREST 与 Nginx 等其他工具，配合使用也非常方便，这样以数据为中心的 CRUD 操作与其他问题就开业完全分开了。

使用 PostgREST 可以替代手动 CRUD 编程数据库的操作。自定义 API 服务器会遇到问题，编写业务逻辑常常会重复，忽略或破坏数据库的结构，会导致直接使用 SQL 语句操作变的很慢。PostgREST 的哲学是建立了一个单一的声明性事实源：数据本身。

---

## 2. 使用二进制运行

- 如果你已经非常熟悉 PostgreSQL 且可以将其安装在系统上的话，可以直接按照你理解的方式部署。 但是为了方便起见，我们这里直接使用容器启动 Postgres 数据库。

```bash
# 暴露5432端口到主机系统
$ docker run -p 5432:5432 --name postgrest_web \
     -e POSTGRES_PASSWORD=postgrest \
     -d postgres:latest
```

- 接下来，我们需要为 API 创建数据库。运行如下命令进入数据库，创建一个路由端点为 /todos 的表并插入部分数据进去。接下来，为匿名的 web 请求创建一个角色。当请求进入时，PostgREST 将切换到数据库中的这个角色来运行查询。

```bash
# 进入容器
$ docker exec -it postgrest_web psql -U postgres
psql (10.12 (Debian 10.12-2.pgdg90+1))
Type "help" for help.
```

```bash
# 创建API的数据库
postgres=# create schema api;

# 创建/todos表
postgres=# create table api.todos (
  id serial primary key,
  done boolean not null default false,
  task text not null,
  due timestamptz
);

# 插入部分数据
postgres=# insert into api.todos (task) values
  ('finish tutorial 0'), ('pat self on back');

# 创建web_anon角色并赋权限
# 匿名请求对todos表具有只读访问权限
postgres=# create role web_anon nologin;
postgres=# grant usage on schema api to web_anon;
postgres=# grant select on api.todos to web_anon;

# 创建todo_user角色并赋权限
# todo用户有权对todo列表执行任何操作
postgres=# create role todo_user nologin;
postgres=# grant todo_user to authenticator;
postgres=# grant usage on schema api to todo_user;
postgres=# grant all on api.todos to todo_user;
postgres=# grant usage, select on sequence api.todos_id_seq to todo_user;
```

- 接下来就是启动我们的 PostgREST 服务了，但是首先需要根据之前的数据库，生成对应的 tutorial.conf 配置文件，在服务启动的时候进行使用。

```bash
db-uri = "postgres://postgres:postgrest@localhost:5432/postgres"
db-schema = "api"
db-anon-role = "web_anon"
db-pool = 10
db-pool-timeout = 10
server-port = 3000
```

- 然后我们通过项目中已经编译好的二进制文件运行 PostgREST 服务，需要注意的话，你需要根据自己操作系统选择不同的二进制版本。

```bash
# 解压二进制压缩包
$ tar -xfJ postgrest-<version>-<platform>.tar.xz

# 运行服务
$ ./postgrest tutorial.conf
Listening on port 3000
Attempting to connect to the database...
Connection successful
```

- 现在就可以使用 curl 或者 postman 等工具来进行测试请求了。

```bash
# 测试请求是否正常
$ curl http://localhost:3000/todos
[
  {
    "id": 1,
    "done": false,
    "task": "finish tutorial 0",
    "due": null
  },
  {
    "id": 2,
    "done": false,
    "task": "pat self on back",
    "due": null
  }
]
```

---

## 3. 使用容器运行

使用容器运行的话，就非常方便了。

```yaml
version: "3"

services:
    postgres:
      restart: on-failure
      container_name: postgrest_pg
      image: postgres
      ports:
        - "5432:5432"
      volumes:
        - "./postgrest_pg:/var/lib/postgresql/data"
      environment:
        - POSTGRES_DB: app_db
        - POSTGRES_USER: app_user
        - POSTGRES_PASSWORD: postgrest
      networks:
        - postgrest_network

    postgrest:
      restart: on-failure
      container_name: postgrest_web
      image: postgrest/postgrest
      ports:
        - "3000:3000"
      environment:
        - PGRST_DB_URI: postgres://app_user:postgrest@postgres:5432/app_db
        - PGRST_DB_SCHEMA: app_db
        - PGRST_DB_ANON_ROLE: app_user
      networks:
        - postgrest_network
      depends_on:
        - postgres

networks:
  postgrest_network:
```
