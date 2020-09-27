# Wait For Ready

> **解决运行Compose文件，服务启动依赖关系问题**

```bash
# 直接执行
$ ./wait_for_ready.sh --help
Usage: wait_for_ready.sh IP:PORT [-t|--timeout <arg>] [--strict|--no-strict] [--quiet|--no-quiet] [-- <arg>] [-h|--help]
        IP: Host or IP under test (no default)
        PORT: TCP port under test (no default)
        -t: Timeout in seconds and zero for no timeout (default 15s)
        --strict: Only execute subcommand if the test succeeds (default off)
        --quiet: Don not output any status messages (default off)
        -- command: Execute command with args after the test finishes (no default)
        -h/--help: Prints help
```
