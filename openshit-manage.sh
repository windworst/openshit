#!/bin/bash
SCRIPT_NAME=openshit-manage.sh
CONFIG_FILE=openshit.conf
SERVICE_PATH=service
SERVICE_ENV_FILE=service-env.sh
ADMIN_ENV_FILE=admin-env.sh

do_export()
{
  if [ ! -e $CONFIG_FILE ]; then
    echo "$CONFIG_FILE not exsit"
    exit 1
  fi

  source $CONFIG_FILE
}

# args: dbname password
set_database()
{
  DBNAME=$1
  DBPASS=$2
  echo "Create Database ${DBNAME}"
  echo "DROP DATABASE IF EXISTS ${DBNAME};\
    CREATE DATABASE ${DBNAME};\
    GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBNAME}'@'localhost' \
    IDENTIFIED BY '${DBPASS}';
  GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBNAME}'@'%' \
    IDENTIFIED BY '${DBPASS}';" \
    | mysql -u${SET_MYSQL_USER} -p${SET_MYSQL_PASS}
}

# args: key value file
set_conf_arg()
{
  KEY=$1
  VALUE=$2
  FILE=$3
  echo "${FILE}: ${KEY}${VALUE}"
  sudo sed -i "s/^[#, ]*${KEY}.*/${KEY}${VALUE}/g" ${FILE}
}

help()
{
  echo "usage: "
  for item in `ls -tr $SERVICE_PATH`;
  do
    echo "  " $SCRIPT_NAME $item
  done
}

if [ $# -le 0 ]; then
  help
elif [ -e "${SERVICE_PATH}/"$1 ]; then
  do_export
  source "${SERVICE_PATH}/"$1 $@
else
  help
fi
