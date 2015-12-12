# docker-lemp-symfony2
Docker container: nginx + mysql + php5-fpm + symfony2

```
docker build -t webapp .
```

```
docker run -v /path/to/symfony:/var/www:rw -p 80:80 -d webapp /sbin/my_init --enable-insecure-key
```

```
docker ps
docker exec -i -t container_id bash
```
