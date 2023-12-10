set -e
LIMESURVEY_DB_USERNAME=${LIMESURVEY_DB_USERNAME:-limesurvey}
LIMESURVEY_DB_PASSWORD=${LIMESURVEY_DB_PASSWORD:-password}
LIMESURVEY_DB_HOST=${LIMESURVEY_DB_HOST:-10.1.0.1}
LIMESURVEY_DB_PORT=${LIMESURVEY_DB_PORT:-5432}
LIMESURVEY_DB_NAME=${LIMESURVEY_DB_NAME:-limesurvey}

LIMESURVEY_TEMPLATE='/var/lib/limesurvey/config.php'
LIMESURVEY_CONFIGFILE='/var/www/limesurvey/application/config/config.php'

cat "${LIMESURVEY_TEMPLATE}" | sed -s  's/LIMESURVEY_DB_USERNAME/'"${LIMESURVEY_DB_USERNAME}"'/g' \
                             | sed -s  's/LIMESURVEY_DB_PASSWORD/'"${LIMESURVEY_DB_PASSWORD}"'/g' \
                             | sed -s  's/LIMESURVEY_DB_HOST/'"${LIMESURVEY_DB_HOST}"'/g' \
                             | sed -s  's/LIMESURVEY_DB_PORT/'"${LIMESURVEY_DB_PORT}"'/g' \
                             | sed -s  's/LIMESURVEY_DB_NAME/'"${LIMESURVEY_DB_NAME}"'/g' \
                             > "${LIMESURVEY_CONFIGFILE}"
