> **parallel-ssh 是为小规模自动化而设计的异步并行的 SSH 库!**

**`parallel-ssh`** 是为小规模自动化而设计的异步并行的 `SSH` 库，包括 `pssh`、`pscp`、`prsync`、`pslurp` 和 `pnuke`工具，其源代码使用 `Python`语言编写开发的。该项目最初位于`Google Code`上，是由`Brent N.Chun`编写和维护的，但是由于工作繁忙，`Brent`于`2009`年`10`月将维护工作移交给了`Andrew McNabb`管理。到了 `2012`年的时候，由于`Google Code`的已关闭，该项目一度被废弃，现在也只能在 `Google Code` 的归档中找到当时的版本了。

但是需要注意的是，之前的版本是不支持 `Python3` 的，但是 `Github` 上面有人 `Fork` 了一份，自己进行了改造使其支持 `Python3` 以上的版本了。与此同时，还有一个组织专门针对 `parallel-ssh` 进行了开发和维护，今天看了下很久都没有更新了。有需要的，自己可以自行查阅。

- [ParallelSSH系列工具介绍](https://escapelife.github.io/posts/8c0f83d.html)
- [lilydjwg/pssh - supported on Python 3.5 and later](https://github.com/lilydjwg/pssh)
- [ParallelSSH/parallel-ssh - asynchronous parallel SSH client library](https://github.com/ParallelSSH/parallel-ssh)

- **可扩展性**
  - 支持扩展到百台，甚至上千台主机使用
- **易于使用**
  - 只需两行代码，即可在任意数量的主机上运行命令
- **执行高效**
  - 号称是最快的 `Python SSH` 库可用
- **资源使用**
  - 相比于其他 `Python SSH` 库，其消耗资源最少

| 编号 | 子命令      | 对应功能解释                                            |
| ---- | ----------- | ------------------------------------------------------- |
| 1    | **`pssh`**  | 通过 ssh 协议在多台主机上并行地运行命令                 |
| 2    | **`pscp`**  | 通过 ssh 协议把文件并行地复制到多台主机上               |
| 3    | **`rsync`** | 通过 rsync 协议把文件高效地并行复制到多台主机上         |
| 4    | **`slurp`** | 通过 ssh 协议把文件并行地从多个远程主机复制到中心主机上 |
| 5    | **`pnuke`** | 通过 ssh 协议并行地在多个远程主机上杀死进程             |
