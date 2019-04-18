# Awesome Docker Builder

> 🐚 Escape's awesome docker builder and relate scripts.

![docker](./images/awesome-docker.jpg)

## DockerFiles

| 编号 | 文件名称 | 功能说明 |
| :-----: | :-----: | :----- |
| 1 | [**`celery`**](https://github.com/EscapeLife/awesome-builder/tree/master/DockerFiles/celery) | 引用自Celery项目，用于编写Dockerfile借鉴模板 |
| 2 | [**`goaccess`**](https://github.com/EscapeLife/awesome-builder/tree/master/DockerFiles/goaccess) | 一款开源/实时/具有交互视图界面/命令行的Web日志分析工具 |
| 3 | [**`lsyncd`**](https://github.com/EscapeLife/awesome-builder/tree/master/DockerFiles/lsyncd) | 海量文件实时同步解决方案，支持主备切换使用 |

## Scripts

| 编号 | 文件名称 | 功能说明 |
| :-----: | :-----: | :----- |
| 1 | [**`/etc/ufw/after.rules`**](https://github.com/EscapeLife/awesome-builder/blob/master/Scripts/after.rules) | 解决UFW无法管理Docker发布出来的端口问题 |
| 2 | [**`image2run.sh`**](https://github.com/EscapeLife/awesome-builder/blob/master/Scripts/image2run.sh) | 将docker镜像导出的tar包转换成为压缩小/自解压/自导入的run包 |
| 3 | [**`kill_all_process.sh`**](https://github.com/EscapeLife/awesome-builder/blob/master/Scripts/kill_all_process.sh) | 解决在Linux系统中程序意外退出删除进程树，防止孤儿进程的出现 |
| 4 | [**`wait_for_ready.sh`**](https://github.com/EscapeLife/awesome-builder/blob/master/Scripts/wait_for_ready.sh) | 解决运行Compose文件，服务启动依赖关系问题 |
