# init container
FROM trikorasolns_glpi_core:latest

ARG GLPI_CONFIG_DIR=/etc/glpi
ARG GLPI_FILES_DIR=/var/lib/glpi
ARG GLPI_LOG_DIR=/var/log/glpi
ARG GLPI_OPT_DIR=/opt/glpi
ARG HTTP_WWW=/var/www/html
ARG GLPI_WWW=${HTTP_WWW}/glpi

VOLUME $GLPI_FILES_DIR
VOLUME $GLPI_CONFIG_DIR
VOLUME $GLPI_LOG_DIR

CMD ['php', ${GLPI_WWW}+'/front/cron.php']
