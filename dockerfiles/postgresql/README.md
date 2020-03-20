# Postgresql高可用配置

> **主要使用的是Postgresql主备流复制的技术来配置高可用的**
> - `https://github.com/pgpool/pgpool2`
> - `https://my.oschina.net/u/3308173/blog/900093`

---

## 1. PGPool2工具介绍

> **可在master和slave上都进行配置，以便实现pgpool2高可用**

- **工具简介**

`pgpool-II` 是一个位于 `PostgreSQL` 服务器和 `PostgreSQL` 数据库客户端之间的中间件，它提供以下主要功能：链接池、负载均衡、节点`failover`(配置主备切换) 更多介绍请点击这里

- **功能特点**

xxx

---

## 2. PGPool2安装方式

> ****

```bash
# 从该网站获取源码安装
# https://launchpad.net/ubuntu/+source/pgpool2/4.0.2-1
$ wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/pgpool2/4.0.2-1/pgpool2_4.0.2.orig.tar.gz
```

```bash
# 解压并进入对应目录
$ mkdir /opt/pgpool
$ tar -zxvf pgpool2_4.0.2.orig.tar.gz
$ cd pgpool-II-4.0.2

# 安装工具依赖包
$ sudo apt update && apt install -y build-essential libpq-dev

# 源代码安装方式
$ sudo ./configure --prefix=/opt/pgpool
$ sudo make
$ sudo make install
```

---

## 3. PGPool2配置操作

> ****

1. 使用ssh配置是master和slave节点服务器可以免密码登陆

2. pool_hba.conf，内容与postgres配置中的pg_hba.conf保持一致

3. 配置pcp管理工具密码（如果不需要通过pgpool登陆数据库，则该步可以省略）

```bash
pg_md5 pwd
vim /etc/pgpool-II/pcp.conf #加入上一步加密的密码(该文件可以cp pcp.conf.sample pcp.conf)
e.g: postgres:01b114342d7fc811669eb24dbe609cc4
```

4. pgpool.conf

```bash
# CONNECTIONS
listen_addresses = '*'
port = 9999
pcp_listen_addresses = '*'
pcp_port = 9898

# - Backend Connection Settings -
backend_hostname0 = 'master_server_ip'
backend_port0 = 5432
backend_weight0 = 1
backend_data_directory0 = '/var/lib/postgresql/data'
backend_flag0 = 'ALLOW_TO_FAILOVER'

backend_hostname1 = 'slave_server_ip'
backend_port1 = 5432
backend_weight1 = 1
backend_data_directory1 = '/var/lib/postgresql/data'
backend_flag1 = 'ALLOW_TO_FAILOVER'

# FILE LOCATIONS
pid_file_name = '/var/run/pgpool/pgpool.pid'

# REPLICATION MODE
replication_mode = off

# LOAD BALANCING MODE
load_balance_mode = on

# MASTER/SLAVE MODE
master_slave_mode = on
master_slave_sub_mode = 'stream'

# Streaming
sr_check_period = 5
sr_check_user = 'postgres'
sr_check_password = ''
sr_check_database = 'postgres'

# HEALTH CHECK MODE
health_check_period = 5 # Health check period,Disabled (0) by default
health_check_timeout = 20 # Health check timeout, 0 means no timeout
health_check_user = 'postgres'
health_check_password = ''
health_check_database = 'postgres'
#必须设置，否则primary数据库down了，pgpool不知道，不能及时切换。从库流复制还在连接数据，报连接失败。
#只有下次使用pgpool登录时，发现连接不上，然后报错，这时候，才知道挂了，pgpool进行切换。

# FAILOVER
failover_command = '/opt/pgpool/failover_stream.sh master_server_ip'
failback_command = ''

# WATCHDOG
# 该部分需要时具体配置

# heartbeat mode
heartbeat_destination0 = 'node_ip'
heartbeat_device0 = 'eth0' # 根据网卡信息填写
```

6. 编写failover_steamer.sh脚本

```
#! /bin/sh
# Failover command for streaming replication.
# Arguments: $1: new master hostname.


new_master=$1
PGDATA=/var/lib/postgresql/data
trigger_command="$PGHOME/bin/pg_ctl promote -D $PGDATA"

# Prompte standby database.
/usr/bin/ssh -T $new_master $trigger_command

exit 0;
```

6. 以上配置可以都是在postgres用户下创建

```bash

```

7. 修改相关文件目录的权限

```bash
chown -R postgres.postgres /opt/pgpool
chmod 777  /opt/pgpool/failover_stream.sh
mkdir /var/log/pgpool
chown -R postgres.postgres /var/log/pgpool
mkdir /var/run/pgpool
chown -R postgres.postgres /var/run/pgpool
```

8. 启动pgpool

```bash
pgpool -f /opt/pgpool/etc/pgpool.conf -n -d -D > /var/log/pgpool/pgpool.log 2>&1 &
```

---

## 4. PGPool2存在问题

当 `master down` 掉以后 `pgpool` 会进行一次主备切换，等角色恢复以后，需要重启一次 `pgpool` 服务才能让以后的 `failover` 有效执行，应该是我没有找到合适的配置项导致的。
