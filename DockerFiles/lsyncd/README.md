## Rsyncd Service Image

> This image allow sync files between servers.

### 1. run as master (receive files from slave)

```bash
docker run -d --name=rsyncd_master \
    -v /data:/data \
    -p 873:873 \
    bohr.cheftin.com:5000/rsyncd [--password xxxxx]
```

### 2. run as slave (send files to master)

Adjust inotify args

```bash
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

Run

```bash
docker run -d --name=rsyncd_slave \
    -v /data:/data \
    bohr.cheftin.com:5000/rsyncd --slave \
    --ip master_ip \
    [--port 873] \
    [--limit 1000] \
    [--password xxxxx ] \
    [--dest /some_path ] \
    [--exclude /some/path/exclude] \
    [--delete]
```

### 3. parameter interpretation

| number | parameter | annotation |
| :----- | :----- | :----- |
| 1 | `--ip` | set master sync server ip.  |
| 2 | `--port` | master rsync domain service port, default is `873`. |
| 3 | `--limit` | limit socket I/O bandwidth. |
| 4 | `--exclude` | rsync exclude path. |
| 5 | `--dest` | the prefix of destination path in master side, default is `/` |
| 6 | `--password` | set the password for rsync, default is `Zorx0jbMzgXD`. |
| 7 | `--delete` | if you delete files in slave, the deleted files in master is not delete, set `--delete` could delete this files on master, default is false. |