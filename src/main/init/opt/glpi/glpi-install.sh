#!/usr/bin/env bash
SCRIPT_VERSION=0.0.1

NC='\033[0m' # No Color
COLOR_RESET="\033[0m" # Reset color
BLACK="\033[0;30m"
BLUE='\033[0;34m'
BROWN="\033[0;33m"
GREEN='\033[0;32m'
GREY="\033[0;90m"
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RED='\033[0;31m'
PURPLE="\033[0;35m"
WHITE='\033[0;37m'
YELLOW='\033[0;33m'

log_message() {
    VERBOSITY_LEVEL=$1
    MESSAGE="${@:2}"
    if [[ ${LOGGING_VERBOSITY} -ge ${VERBOSITY_LEVEL} ]]; then
        echo -e "${MESSAGE}"
    fi
}

log_message_nonl() {
    VERBOSITY_LEVEL=$1
    MESSAGE="${@:2}"
    if [[ "${LOGGING_VERBOSITY}" -ge "${VERBOSITY_LEVEL}" ]]; then
        echo -ne "${MESSAGE}\033[0K\r"
    fi
}

msg() {
    VERBOSITY_LEVEL=${1}
    COLOR=${2}
    MSG="${@:3}"
    # echo -e "\n${!COLOR}## ${MSG}${NC}"
    log_message ${VERBOSITY_LEVEL} "\n${!COLOR}## ${MSG}${NC}"
}

succeeded() {
    VERBOSITY_LEVEL=$1
    MSG="${@:2}"
#   echo -e "${GREEN}NOTE:${NC} $1"
    # log_message ${VERBOSITY_LEVEL} "${GREEN}\xE2\x9C\x85${NC} ${MSG}"
    log_message ${VERBOSITY_LEVEL} "${GREEN}\xE2\x9C\x94${NC} ${MSG}"
}

note() {
    VERBOSITY_LEVEL=$1
    MSG="${@:2}"
#   echo -e "${BLUE}NOTE:${NC} $1"
    log_message ${VERBOSITY_LEVEL} "${BLUE}!${NC} ${MSG}"
}

note_start_task() {
    VERBOSITY_LEVEL=$1
    MSG="${@:2}"
#   echo -e "${BLUE}NOTE:${NC} $1"
    log_message_nonl ${VERBOSITY_LEVEL} "${BLUE}!${NC} ${MSG}"
}

warn() {
#   echo -e "${YELLOW}WARN:${NC} $1"
    log_message 1 "${YELLOW}\xE2\x9A\xA0${NC} $1"
}

error() {
#   echo -e "${RED}ERROR:${NC} $1"
    log_message 0 "${RED}\xE2\x9D\x8C${NC} $1"
}

generate_configuration() {
    note_start_task 0 "generate_db_configuration()"
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
    succeeded 0 "generate_db_configuration()"
    cat /etc/glpi/local_define.php

    note_start_task 0 "generate_local_define()"
    cp /opt/glpi/local_define.php /etc/glpi/local_define.php
#     cat <<EOF > /etc/glpi/local_define.php
# <?php
# define('GLPI_FILES_DIR', '/var/lib/glpi');
# define('GLPI_VAR_DIR',          GLPI_FILES_DIR);
# define('GLPI_DOC_DIR',          GLPI_FILES_DIR);
# define('GLPI_CACHE_DIR',        GLPI_FILES_DIR . '/_cache');
# define('GLPI_CRON_DIR',         GLPI_FILES_DIR . '/_cron');
# define('GLPI_DUMP_DIR',         GLPI_FILES_DIR . '/_dumps');
# define('GLPI_GRAPH_DIR',        GLPI_FILES_DIR . '/_graphs');
# define('GLPI_LOCAL_I18N_DIR',   GLPI_FILES_DIR . '/_locales');
# define('GLPI_LOCK_DIR',         GLPI_FILES_DIR . '/_lock');
# define('GLPI_PICTURE_DIR',      GLPI_FILES_DIR . '/_pictures');
# define('GLPI_PLUGIN_DOC_DIR',   GLPI_FILES_DIR . '/_plugins');
# define('GLPI_RSS_DIR',          GLPI_FILES_DIR . '/_rss');
# define('GLPI_SESSION_DIR',      GLPI_FILES_DIR . '/_sessions');
# define('GLPI_TMP_DIR',          GLPI_FILES_DIR . '/_tmp');
# define('GLPI_UPLOAD_DIR',       GLPI_FILES_DIR . '/_uploads');
# define('GLPI_UPLOAD_DIR',       GLPI_FILES_DIR . '/_uploads');
# define('GLPI_INVENTORY_DIR',    GLPI_FILES_DIR . '/_inventories');
# define('GLPI_MARKETPLACE_DIR',  GLPI_FILES_DIR . '/marketplace');

# define('GLPI_LOG_DIR', '/var/log/glpi');
# EOF
    succeeded 0 "generate_local_define()"
    note 0 "print local_define()"
    cat /etc/glpi/local_define.php
    note 0 "/print local_define()"
}

install_fs() {
    note 0 "install_fs()"
    mkdir -p /var/lib/glpi/{_cache/templates,'_cron','_dumps','_graphs','_lock','_pictures','_plugins','_rss','_sessions','_tmp','_uploads'}
    # chown 33:33 -R /var/lib/glpi/_cache
    chown 33:33 -R /var/lib/glpi/
}

install_db() {
    note 0 "install_db()"
    php bin/console db:install ${GLPI_INSTALL_DEFAULT_OPTIONS}
    GLPI_INSTALL_RESULT=$?
    succeeded 0 "Database installed: ${GLPI_INSTALL_RESULT}"
}

update_db() {
    note 0 "update_db()"
    php bin/console db:update --no-interaction --no-telemetry
    php bin/console migration:utf8mb4
    php bin/console migration:unsigned_keys
}

validate_environment() {
    note_start_task 0 "validate_environment()"
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
    if [ ! -v GLPI_LANGUAGE ]; then
        error "Missing GLPI_LANGUAGE"
        exit 1
    fi
    succeeded 0 "validate_environment()"
}

# Recover the glpicrypt.key file
recover_glpi_key() {
    note 0 "recover_glpi_key()"
    # The GLPI_CRYPT environmenv variable should have this file on a base64 encoded tar gzip file.
    note 0 "GLPI_CRYPT: ${GLPI_CRYPT}:${#GLPI_CRYPT}"
    if [ -v GLPI_CRYPT ] && [ ${#GLPI_CRYPT} > 0 ] ; then
        note 0 "Extract provided GLPI crypt file to /etc/glpi"
        echo "${GLPI_CRYPT}" | base64 -d > /tmp/glpicrypt.tgz
        pushd /tmp
        tar xzvf /tmp/glpicrypt.tgz
        # GLPI_CONFIG_DIR variable from downstream.php
        mv glpicrypt.key /etc/glpi/
        popd
        success 0 "Extract provided GLPI crypt file to /etc/glpi"
        ls -l /etc/glpi/
    else
        note 0 "No GLPI crypt file provided."
    fi
}

###### Execution

note 0 "Script version: ${SCRIPT_VERSION}"

php bin/console system:check_requirements

# Check installation
# php bin/console db:check_schema_integrity
# if [ $? -eq 1 ]; then
#     validate_environment
#     generate_db_configuration
# end

recover_glpi_key

if [ ! -v LOGGING_VERBOSITY ]; then
    LOGGING_VERBOSITY=0
fi
note 0 "whoami: $(whoami)"
note 0 "groups: $(groups)"

# ls -l /var/lib
# ls -l /var/lib/glpi
note 0 "GLPI_DB_HOST: ${GLPI_DB_HOST}"
note 0 "GLPI_DB_PORT: ${GLPI_DB_PORT}"
note 0 "GLPI_DB_USER_NAME: ${GLPI_DB_USER_NAME}"
# note 0 "GLPI_DB_USER_PASSWORD: ${GLPI_DB_USER_PASSWORD}"
note 0 "GLPI_DB_NAME: ${GLPI_DB_NAME}"
note 0 "GLPI_LANGUAGE: ${GLPI_LANGUAGE}"

#cat /etc/glpi/config_db.php

validate_environment
generate_configuration

#cat /etc/glpi/config_db.php
note 0 'Check schema integrity'
php bin/console db:check_schema_integrity
CHECK_INTEGRITY_RES=$?
note 0 "CHECK_INTEGRITY_RES: ${CHECK_INTEGRITY_RES}"
if [ $CHECK_INTEGRITY_RES -eq 1 ] || [ $CHECK_INTEGRITY_RES -eq 4 ]; then
    if [ ! -v GLPI_INSTALL_DEFAULT_OPTIONS ]; then
        GLPI_INSTALL_DEFAULT_OPTIONS="--default-language=${GLPI_LANGUAGE} --no-interaction --no-telemetry"
    fi
    install_fs
    install_db
# elif [ ! $? -eq 0 ]; then

else
    update_db 
fi

# case ${INIT_ACTION} in
#     install) 
#         install_fs
#         install_db 
#         ;;
#     update) 
#         update_db 
#         ;;
#     *) 
#         php bin/console db:check_schema_integrity
#         if [ $? -eq 4 ]; then
#             install_glpi
#         elif [ ! $? -eq 0 ]; then
            
#         fi
#         ;; 
# esac;
