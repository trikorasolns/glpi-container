# 10.0.6
FROM alpine:3.17.2 as unzipper
ARG GLPI_VERSION="10.0.6"

RUN apk add curl
RUN mkdir /opt/ ; \
  curl https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz -L | tar xvzf - -C /opt

FROM php:8.1-apache

ENV GLPI_CONFIG_DIR=/etc/glpi
ENV GLPI_VAR_DIR=/var/lib/glpi
ENV GLPI_LOG_DIR=/var/log/glpi

RUN mkdir ${GLPI_CONFIG_DIR}

#RUN php -m

# RUN apt update && apt install -y php8.1-intl && rm -rf /var/lib/apt/lists/*
#RUN apt update && apt install -y zlib1g-dev libpng-dev php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath && rm -rf /var/lib/apt/lists/*
# Mandatory extensions: curl
# Optional Extensions: cli domxml xmlrpc APCu
#RUN docker-php-ext-install mysqli pdo pdo_mysql fileinfo gd json mbstring session zlib simplexml xml intl ldap openssl zlib && docker-php-ext-enable pdo_mysql
# fileinfo  json mbstring session zlib simplexml xml intl ldap openssl zlib 
RUN apt update \
&& apt install -y zlib1g-dev libpng-dev libicu-dev g++ \
&& rm -rf /var/lib/apt/lists/* \
&& docker-php-ext-configure intl \
&& docker-php-ext-install gd intl mysqli pdo pdo_mysql \
&& docker-php-ext-enable mysqli
#RUN php -m

COPY glpi/php/* /usr/local/etc/php/

COPY  --from=unzipper /opt/glpi/files $GLPI_VAR_DIR
COPY  --from=unzipper /opt/glpi/config $GLPI_CONFIG_DIR

COPY  --from=unzipper /opt/ /var/www/

RUN rm -Rf /var/www/glpi/files /var/www/glpi/config

VOLUME $GLPI_VAR_DIR
VOLUME $GLPI_LOG_DIR

WORKDIR /var/www/glpi

EXPOSE 80
EXPOSE 443

