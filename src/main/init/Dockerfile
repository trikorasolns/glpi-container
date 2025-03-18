# init container
FROM trikorasolns_glpi_core:latest

ARG GLPI_CONFIG_DIR=/etc/glpi
ARG GLPI_FILES_DIR=/var/lib/glpi
ARG GLPI_LOG_DIR=/var/log/glpi
ARG GLPI_OPT_DIR=/opt/glpi
ENV GLPI_OPT_DIR=${GLPI_OPT_DIR}

COPY src/main/init/opt/glpi/* ${GLPI_OPT_DIR}/

RUN chown -R www-data:www-data ${GLPI_OPT_DIR} \
  && chmod 755  ${GLPI_OPT_DIR}/glpi-install.sh

VOLUME $GLPI_FILES_DIR
VOLUME $GLPI_CONFIG_DIR
VOLUME $GLPI_LOG_DIR

CMD ["/opt/glpi/glpi-install.sh"]
