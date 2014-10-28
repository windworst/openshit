#!/bin/bash
SCRIPT_NAME=openshit.sh
CONFIG_FILE=setting.conf
SERVICE_PATH=services
SERVICE_ENV_FILE=service-env.sh
ADMIN_ENV_FILE=admin-env.sh

# args: FILE_NAME
load_file()
{
  local FILE_NAME=$1
  if [ ! -e $FILE_NAME ]; then
    echo "$FILE_NAME not exsit"
    exit 1
  fi
  source $FILE_NAME
}

load_conf()
{
 load_file $CONFIG_FILE
}

load_admin_env()
{
  load_file $ADMIN_ENV_FILE
}

load_service_env()
{
  load_file $SERVICE_ENV_FILE
}

# args: dbname
drop_database()
{
  local DBNAME=$1
  echo "Drop Database ${DBNAME}"
  echo "DROP DATABASE IF EXISTS ${DBNAME};" \
  | mysql -u${SET_MYSQL_USER} -p${SET_MYSQL_PASS}
}
# args: dbname password
set_database()
{
  local DBNAME=$1
  local DBPASS=$2
  echo "Set Database ${DBNAME}"
  echo "CREATE DATABASE IF NOT EXISTS ${DBNAME};
  GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBNAME}'@'localhost' \
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

  sudo grep -q "^$SECTION" $FILE 2>/dev/null
  if [ $? -eq 0 ]; then
    while (($count<=$#));
    do
      sudo grep -q "^[#, ]*${!count}.*" $FILE 2>/dev/null
      if [ $? -ne 0 ]; then
        sudo sed -i "s/^[#, ]*${SECTION}.*/${SECTION}\n${!count}/g" $FILE
      fi
      let ++count
    done
  else
    sudo sh -c "echo ${SECTION} >> ${FILE}"
    while (($count<=$#));
    do
      sudo grep -q "^[#, ]*${!count}.*" $FILE 2>/dev/null
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

# args : package-list
run_install()
{
  echo "Installing: $@"
  sudo apt-get -y install $@
}

# args : package-list
run_download()
{
  echo "Downloading: $@"
  sudo apt-get -y -d install $@
}

# args : package-list
run_uninstall()
{
  echo "Uninstalling: $@"
  sudo apt-get -y --purge remove $@
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
  load_conf
  SERVICE_NAME=$1
  source "${SERVICE_PATH}/"$1 $@
else
  help
fi
