# Graylog

> **服务日志收集方案：Filebeat + Graylog！**

当我们公司内部部署很多服务以及测试、正式环境的时候，查看日志就变成了一个非常刚需的需求了。是多个环境的日志统一收集，然后使用 `Nginx` 对外提供服务，还是使用专用的日志收集服务 `ELK` 呢？这就变成了一个问题！而 `Graylog` 作为整合方案，使用 `elasticsearch` 来存储，使用 `mongodb` 来缓存，并且还有带流量控制的 (`throttling`)，同时其界面查询简单易用且易于扩展。所以，使用 `Graylog` 成为了不二之选，为我们省了不少心。

![Graylog](../../images/dockerfiles/linux-graylog-tool.jpg)
