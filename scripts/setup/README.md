# Setup

> **一个Python程序打包的示例setup.py配置脚本文件**

当然，这里我们是通过执行命令直接打包：

```bash
# create python lib package
$ python3 setup.py bdist_wheel
```

同时，打包脚本中还提供了一个打包的 `upload` 子命令，用于一键打包、推送(`twine`)和改打标记(`tag`)：

```python
# a key deployment
$ python3 setup.py upload
```
