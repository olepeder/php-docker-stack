# PHP Docker template

Kilde: <https://github.com/GaryClarke/docker-php>

Tech stack:

- PHP v. 8.3
- Docker
- MySQL 9.1.0
- Composer 2.4 (package manager for PHP)

## Hvordan bruke

```shell
# start PHP
docker compose up -d
```

## Nyttige kommandoer

### 3 måter å vise kjørende containere

```shell

# 1. Vis alle kjørende containere på host
docker ps

CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS         PORTS                  NAMES
920bf723f50d   nginx:latest   "/docker-entrypoint.…"   About a minute ago   Up 2 seconds   0.0.0.0:8080->80/tcp   php-docker-stack-web-1

# 2. Vis tjenester kjørende i compose fil
docker compose ps

NAME                     IMAGE          COMMAND                  SERVICE   CREATED         STATUS         PORTS
php-docker-stack-web-1   nginx:latest   "/docker-entrypoint.…"   web       6 minutes ago   Up 5 minutes   0.0.0.0:8080->80/tcp

# 3. Se i Docker Desktop
```

### bygge et image fra Dockerfile

```shell
docker build -t olepg:php8.3 -f php/Dockerfile .

[+] Building 15.0s (7/7) FINISHED                                                          docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                       0.0s
 => => transferring dockerfile: 98B                                                                        0.0s
 => [internal] load metadata for docker.io/library/php:8.3-fpm-alpine                                      6.0s
 => [auth] library/php:pull token for registry-1.docker.io                                                 0.0s
 => [internal] load .dockerignore                                                                          0.0s
 => => transferring context: 2B                                                                            0.0s
 => [1/2] FROM docker.io/library/php:8.3-fpm-alpine@sha256:e33c5c3be36c66846266d71475f47f88cf3ce05361ad2e  1.7s
 => => resolve docker.io/library/php:8.3-fpm-alpine@sha256:e33c5c3be36c66846266d71475f47f88cf3ce05361ad2e  0.0s
...
 => => extracting sha256:c0479a54d94ce667b3dee2ef941cd12f8798e5d1e638fb3e6f4ff199269606e3                  0.0s
 => [2/2] RUN docker-php-ext-install pdo_mysql                                                             7.3s
 => exporting to image                                                                                     0.0s
 => => exporting layers                                                                                    0.0s
 => => writing image sha256:c6b675ca5e6696573864561a729b39ac1b07c6d4e63e83427bca28eb5bbaaff6               0.0s
 => => naming to docker.io/library/olepg:php8.3                                                            0.0s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/zldjbgqenju1xuz1b7fg5xhfl
```

### vis images på host

```shell
docker images

REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
olepg        php8.3    c6b675ca5e66   6 minutes ago   78.6MB
```

### slett alle "dangling" images

```shell
docker image prune
```

### åpne shell i en container. Her vises f.eks. nginx config fil

```shell
docker exec -it php-docker-stack-web-1 sh

pwd
/
cat /etc/nginx/conf.d/default.conf
```

```nginx
# NGINX config file: default.config for PHP FPM
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}

#
```

### Vis working dir ved å exec inn i container og se hvilken katalog som kommer opp

```shell

docker exec -it php-docker-stack-app-1 sh

/var/www/html #

exit
```

### specify docker-compose fil

```shell
docker compose -f docker-compose.dev.yaml up --build -d
```

### run PHP composer install in local app dir to install packages

Flag --ignore-platform-reqs forteller installer at den skal ignore hva som er installert av php på local maskin. composer.json bestemmer hvilken php versjon den skal forholde seg til.

Docs: <https://getcomposer.org/>

```shell
cd app

composer install --ignore-platform-reqs

# aktiver auto-load
composer dump-autoload
```

### specify environment file

Brukes bare hvis det ikke er .env fil (standard filnavn) som skal brukes

```shell
docker compose -f docker-compose.dev.yaml up --env-file .env --build -d
```

### send inn env variabler i forbindelse med docker compose

```shell
XDEBUG_MODE=debug docker compose -f docker-compose.dev.yaml up --env-file .env.local --build -d
```

Sjekk om debug mode er aktivert med å legge inn `xdebug_info();` i PHP koden
