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

# args: dbname
init_database()
{
  local DBNAME=$1
  echo "Init Database ${DBNAME}"
  echo "DROP DATABASE IF EXISTS ${DBNAME};\
    CREATE DATABASE ${DBNAME};" \
  | mysql -u${SET_MYSQL_USER} -p${SET_MYSQL_PASS}
}
# args: dbname password
set_database()
{
  local DBNAME=$1
  local DBPASS=$2
  echo "Config Database ${DBNAME}"
  echo "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBNAME}'@'localhost' \
    IDENTIFIED BY '${DBPASS}';
  GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBNAME}'@'%' \
    IDENTIFIED BY '${DBPASS}';" \
    | mysql -u${SET_MYSQL_USER} -p${SET_MYSQL_PASS}
}

#args: file section arg1 arg2 arg3 ......
add_args_to_section()
{
  local FILE=$1
  local SECTION=$2
  local count=3
  if [ $# -lt $count ]; then
    return
  fi

  grep -q $SECTION $FILE 2>/dev/null
  if [ $? -eq 0 ]; then
    while (($count<=$#));
    do
      grep -q ${!count} $FILE 2>/dev/null
      if [ $? -ne 0 ]; then
        sudo sed -i "s/${SECTION}/${SECTION}\n${!count}/g" $FILE
      fi
      let ++count
    done
  else
    sudo sh -c "echo ${SECTION} >> ${FILE}"
    while (($count<=$#));
    do
      grep -q ${!count} $FILE 2>/dev/null
      if [ $? -ne 0 ]; then
        sudo sh -c "echo ${!count} >> ${FILE}"
      fi
      let ++count
    done
  fi
}

# args: old new file
set_conf_arg()
{
  local OLD=$1
  local NEW=$2
  local FILE=$3
  echo "${FILE}: ${NEW}"
  sudo sed -i "s|^[#, ]*${OLD}.*|${NEW}|g" ${FILE}
}

# args: service name
remove_service()
{
  local SERVICE_NAME=$1
  keystone user-delete $SERVICE_NAME
  keystone service-delete $SERVICE_NAME
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
