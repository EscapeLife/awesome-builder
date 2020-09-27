# Docker Patch

> **一个快速迭代的Docker补丁包部署的小程序**

## 1. 安装依赖包

```bash
# requirements
$ pip3 install -y sh click gitpython prompt_toolkit
```

## 2. 工具使用方式

```bash
# 查看帮助信息
$ python3 docker_patch.py --help

# 交互式运行
$ sudo python3 docker_patch.py

# 给定参数运行
$ sudo python3 docker_patch.py
    --code_path='/data/app' \
    --code_branch='master' \
    --config_name='docker' \
    --start_commit='aaaaaa' --end_commit='bbbbbb' \
    --images_name='xxxxx/xxxxx:0.0.1'
```
