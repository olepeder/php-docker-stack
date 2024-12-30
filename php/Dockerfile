FROM php:8.3-fpm-alpine AS app

# Useful PHP extensin installer image, copy binary into your container
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

# Install php extensions
# med flag for exit on errors, exit on unset variables, print every command as it is executed
RUN set -eux; \
  install-php-extensions pdo pdo_mysql;

# Install php extensions - brukes ikke  - install-php-extensions er en bedre måte å installere extensions
# RUN docker-php-ext-install pdo pdo_mysql

# allow super user - set this if you use Composer as a
# super user at all times like in docker containers
ENV COMPOSER_ALLOW_SUPERUSER=1

# obtain composer using multi-stage build
# https://docs.docker.com/build/building/multi-stage/
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

#Here, we are copying only composer.json and composer.lock (instead of copying the entire source)
# right before doing composer install.
# This is enough to take advantage of docker cache and composer install will
# be executed only when composer.json or composer.lock have indeed changed!-
# https://medium.com/@softius/faster-docker-builds-with-composer-install-b4d2b15d0fff
COPY ./app/composer.* ./

# install
RUN composer install --prefer-dist --no-dev --no-scripts --no-progress --no-interaction

# copy application files to the working directory
COPY ./app .

# run composer dump-autoload --optimize
RUN composer dump-autoload --optimize


# Dev image
# This stage is meant to be target-built into a separate image
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target
FROM app AS app_dev

ENV XDEBUG_MODE=off

COPY ./php/conf.d/xdebug.ini $PHP_INI_DIR/conf.d/xdebug.ini
# Bruk $PHP_INI_DIR for å få riktig path til php.ini istedetfor å hardkode som under
# COPY ./php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# install xdebug
RUN set -eux; \
  install-php-extensions xdebug;

