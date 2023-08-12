#!/usr/bin/env bash

error() {
    echo -e "ERROR: $1"
}

generate_db_configuration () {
    cat <<EOF > /etc/glpi/config_db.php
<?php
class DB extends DBmysql {
   public \$dbhost = '${GLPI_DB_HOST}:${GLPI_DB_PORT}';
   public \$dbuser = '${GLPI_DB_USER_NAME}';
   public \$dbpassword = '${GLPI_DB_USER_PASSWORD}';
   public \$dbdefault = '${GLPI_DB_NAME}';
   public \$use_utf8mb4 = true;
   public \$allow_myisam = false;
   public \$allow_datetime = false;
   public \$allow_signed_keys = false;
}
EOF
}

# init_action() {
#     case ${INIT_ACTION} in
#         install) install_db ;;
#         update) update_db ;;
#     esac;
# }

install_db() {
    php bin/console db:install --default-language="${GLPI_LANGUAGE}"
}

update_db() {
    php bin/console db:update
}

validate_environment() {
    if [ ! -v GLPI_DB_HOST ]; then
        error "Missing GLPI_DB_HOST"
        exit 1
    fi
    if [ ! -v GLPI_DB_PORT ]; then
        error "Missing GLPI_DB_PORT"
        exit 1
    fi
    if [ ! -v GLPI_DB_USER_NAME ]; then
        error "Missing GLPI_DB_USER_NAME"
        exit 1
    fi
    if [ ! -v GLPI_DB_USER_PASSWORD ]; then
        error "Missing GLPI_DB_USER_PASSWORD"
        exit 1
    fi
    if [ ! -v GLPI_DB_NAME ]; then
        error "Missing GLPI_DB_NAME"
        exit 1
    fi
}

###### Execution

validate_environment

generate_db_configuration

if [ ! -v GLPI_UPDATE ]; then
    update_db
else
    install_db
fi
