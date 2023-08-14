# Web Application
FROM trikorasolns_glpi_init:latest

ARG HTTP_WWW=/var/www/html
ARG GLPI_WWW=${HTTP_WWW}/glpi
ARG LOCAL_INSTALLATION_FOLDER=src/main/web

COPY ${LOCAL_INSTALLATION_FOLDER}/etc/httpd/sites-enabled/* /etc/apache2/sites-enabled/
COPY ${LOCAL_INSTALLATION_FOLDER}/etc/httpd/ports.conf /etc/apache2/

RUN rm ${GLPI_WWW}/install/install.php

WORKDIR ${GLPI_WWW}

EXPOSE 8080
EXPOSE 8443

