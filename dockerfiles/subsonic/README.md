# Subsonic

- **Build**

```bash
# build subsonic image
$ docker build --squash --no-cache --tag=subsonic:latest .
```

- **Use**

```bash
# run subsonic container
$ docker run -d --restart=always --name=subsonic -p 80:4000 subsonic:latest
```
