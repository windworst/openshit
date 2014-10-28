#!/bin/bash
SCRIPT_NAME=openshit.sh
CONFIG_FILE=setting.conf
SERVICE_FILE=service.conf
SERVICE_PATH=services
SERVICE_ENV_FILE=service-env.sh
ADMIN_ENV_FILE=admin-env.sh
PRE_INSTALL_FILE=pre-install.sh

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

call_pre_install()
{
  if  [ -z $NEED_PRE_INSTALL ]; then
    read -p "Do you need configure your soft-source before install/download? [Y/n]" ret
    if [ -z $ret -o 'Y' = $ret -o 'y' = $ret ]; then
      source $PREINSTALL_FILE
    fi
    NEED_PRE_INSTALL="n"
  elif [ 'y' = $NEED_PRE_INSTALL -o 'Y' = $NEED_PRE_INSTALL ]; then
    source $PRE_INSTALL_FILE
    NEED_PRE_INSTALL="n"
  fi
}

unset PACKAGE_LIST
# env : PACKAGE_LIST ACTION
func_package()
{
  if [ "install" = $1 ]; then
    call_pre_install
    sudo apt-get -y install $PACKAGE_LIST
  elif [ "download" = $1 ]; then
    call_pre_install
    sudo apt-get -y -d install $PACKAGE_LIST
  elif [ "uninstall" = $1 ]; then
    sudo apt-get -y --purge remove $PACKAGE_LIST
  fi
}

unset SERVICE_LIST
# env: SERVICE_LIST ACTION
func_service()
{
  for item in $SERVICE_LIST;
  do
    echo "${ACTION}: ${item}"
    sudo service $item $ACTION
  done
}

INVOKE="func_"

# args: variable or function name
is_usable()
{
  if type "$INVOKE$1" &>/dev/null; then
    return 0
  fi
  return 1
}

# args: actions-list
echo_usable_action()
{
  for item in $@;
  do
    if is_usable $item; then
      echo -n "$item "
    fi
  done
}

help()
{
  echo "usage: "
  for item in `ls -tr $SERVICE_PATH`;
  do
    echo "  " $SCRIPT_NAME $item
  done
}

# args: SERVICE_NAME, ACTION
invoke_service()
{
  unset PACKAGE_LIST
  unset SERVICE_LIST

  local SERVICE_NAME=$1
  local ACTION=$2

  if [ -z "$ACTION" ]; then
    echo "$SERVICE_NAME Support actions:"
    echo -n "  "
    if [ ! -z "$SERVICE_LIST" ]; then
      echo -n "start stop restart "
    fi
    if [ ! -z "$PACKAGE_LIST" ]; then
      echo -n "install download uninstall "
    fi
    echo_usable_action "config clean"
  fi
  echo "[${ACTION}: ${SERVICE_NAME}]"
  if [ ! -z "$SERVICE_LIST" ] && [ "start" = $ACTION -o "stop" = $ACTION -o "restart" = $ACTION  ]; then
    func_service $ACTION
  elif [ ! -z "$PACKAGE_LIST" ] && [ "install" = $ACTION -o "uninstall" = $ACTION -o "download" = $ACTION  ]; then
    func_package $ACTION
  elif is_usable $ACTION; then
    $INVOKE$ACTION
  else
    echo "$SERVICE_NAME: $ACTION Not Implement"
  fi
}

SERVICE_NAME=$1
ACTION=$2

if [ $# -le 0 ]; then
  help
elif [ -e "${SERVICE_PATH}/${SERVICE_NAME}" ]; then
  load_file $CONFIG_FILE
  load_file $SERVICE_FILE
  load_file "${SERVICE_PATH}/${SERVICE_NAME}"
  invoke_service $SERVICE_NAME $ACTION
else
  help
fi
