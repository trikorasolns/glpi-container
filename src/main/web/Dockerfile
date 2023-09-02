# Web Application
FROM trikorasolns_glpi_core:latest

ARG HTTP_WWW=/var/www/html
ARG GLPI_WWW=${HTTP_WWW}/glpi
ARG LOCAL_INSTALLATION_FOLDER=src/main/web
ARG GLPI_CONFIG_DIR=/etc/glpi
ARG GLPI_FILES_DIR=/var/lib/glpi
ARG GLPI_LOG_DIR=/var/log/glpi

COPY ${LOCAL_INSTALLATION_FOLDER}/etc/httpd/sites-enabled/* /etc/apache2/sites-enabled/
COPY ${LOCAL_INSTALLATION_FOLDER}/etc/httpd/ports.conf /etc/apache2/

RUN rm ${GLPI_WWW}/install/install.php

WORKDIR ${GLPI_WWW}

VOLUME $GLPI_CONFIG_DIR
VOLUME $GLPI_FILES_DIR
VOLUME $GLPI_LOG_DIR

EXPOSE 8080
EXPOSE 8443
