# INIT CONTAINER
FROM alpine:3.17.5 as unzipper
ARG GLPI_VERSION="10.0.9"

RUN apk add curl
RUN mkdir /opt/ ; \
  curl https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz -L | tar xvzf - -C /opt \
  && chmod -R 755 /opt/glpi/*.php

# ENV PHP_VERSION=8.1-apache
FROM php:8.1-apache

ARG GLPI_CONFIG_DIR=/etc/glpi
ARG GLPI_OPT_DIR=/opt/glpi
ARG GLPI_VAR_DIR=/var/lib/glpi
ARG GLPI_LOG_DIR=/var/log/glpi
ARG HTTP_WWW=/var/www/html
ARG GLPI_WWW=${HTTP_WWW}/glpi
ARG LOCAL_INSTALLATION_FOLDER=src/main/init

RUN mkdir ${GLPI_CONFIG_DIR} ${GLPI_OPT_DIR}

#RUN php -m

# RUN apt update && apt install -y php8.1-intl && rm -rf /var/lib/apt/lists/*
#RUN apt update && apt install -y zlib1g-dev libpng-dev php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath && rm -rf /var/lib/apt/lists/*
# Mandatory extensions: curl
# Optional Extensions: cli domxml xmlrpc APCu
#RUN docker-php-ext-install mysqli pdo pdo_mysql fileinfo gd json mbstring session zlib simplexml xml intl ldap openssl zlib && docker-php-ext-enable pdo_mysql
# fileinfo  json mbstring session zlib simplexml xml intl ldap openssl zlib 
RUN apt update \
  && apt install -y zlib1g-dev libpng-dev libicu-dev libzip-dev libbz2-dev libldap2-dev \ 
  && rm -rf /var/lib/apt/lists/* \ 
  && docker-php-ext-configure intl \ 
  && docker-php-ext-install gd intl mysqli pdo pdo_mysql zip bz2 exif ldap opcache \ 
  && docker-php-ext-enable mysqli ldap \
  && a2enmod rewrite
#RUN php -m

#COPY web/etc/glpi/php/* /usr/local/etc/php/conf.d/
COPY ${LOCAL_INSTALLATION_FOLDER}/php/* /usr/local/etc/php/conf.d/
RUN rm /etc/apache2/sites-enabled/000-default.conf
# COPY web/etc/glpi/local_define.php /etc/glpi/
COPY ${LOCAL_INSTALLATION_FOLDER}/etc/glpi/* ${GLPI_CONFIG_DIR}/
COPY ${LOCAL_INSTALLATION_FOLDER}/var/www/glpi/inc/downstream.php ${GLPI_WWW}/inc/
COPY src/main/init/script/glpi-install.sh ${GLPI_OPT_DIR}/

COPY  --from=unzipper /opt/glpi/files $GLPI_VAR_DIR
COPY  --from=unzipper /opt/glpi/config $GLPI_CONFIG_DIR

COPY  --from=unzipper /opt/ /var/www/html

RUN mkdir ${GLPI_VAR_DIR}/_templates \
  && chown -R www-data:www-data ${GLPI_WWW} \
  && chown -R www-data:www-data ${GLPI_VAR_DIR} \
  && chown -R www-data:www-data ${GLPI_CONFIG_DIR} \
  && chown -R www-data:www-data ${GLPI_OPT_DIR} \
  && chmod 755  ${GLPI_OPT_DIR}/glpi-install.sh
#  && chmod -R 755 ${GLPI_WWW}/*.php
# && rm -Rf /var/www/glpi/files /var/www/glpi/config

VOLUME $GLPI_VAR_DIR
VOLUME $GLPI_CONFIG_DIR
VOLUME $GLPI_LOG_DIR

WORKDIR ${GLPI_WWW}

EXPOSE 8080
EXPOSE 8443
# EXPOSE 80
# EXPOSE 443

# CMD [${GLPI_OPT}+"/glpi-install.sh"]
