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

# args: service_name
import()
{
  local SERV_NAME=$1
  if ! is_usable $SERV_NAME; then
    echo "$SERV_NAME not detected"
    exit 1
  fi
  load_file "${SERVICE_PATH}/$SERV_NAME"
}

load_admin_env()
{
  load_file $ADMIN_ENV_FILE
}

load_service_env()
{
  load_file $SERVICE_ENV_FILE
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
  export NEED_PRE_INSTALL
  if  [ -z $NEED_PRE_INSTALL ]; then
    read -p "Do you need configure your soft-source by $PRE_INSTALL_FILE [Y/n]" NEED_PRE_INSTALL
  fi
  if [ 'y' = $NEED_PRE_INSTALL -o 'Y' = $NEED_PRE_INSTALL ]; then
    source $PRE_INSTALL_FILE
  fi
  NEED_PRE_INSTALL=n
}

# env : SET_PACKAGE_LIST 
func_install()
{
  call_pre_install
  sudo apt-get -y install $SET_PACKAGE_LIST
}

func_download()
{
  call_pre_install
  sudo apt-get -y -d install $PACKAGE_LIST
}

func_uninstall()
{
  sudo apt-get -y --purge remove $PACKAGE_LIST
  sudo apt-get autoremove
}

# env: SET_SERVICE_LIST
# args: ACTION
func_service()
{
  for item in $SET_SERVICE_LIST;
  do
    echo "$1: ${item}"
    sudo service $item $1
  done
}

INVOKE="func_"

# args: variable or function name
is_usable()
{
  if type "$1" &>/dev/null; then
    return 0
  fi
  return 1
}

# args: actions-list
echo_usable_action()
{
  for item in $@;
  do
    if is_usable $INVOKE$item; then
      echo -n "$item "
    fi
  done
}

help()
{
  echo "usage: "
  for item in `ls $SERVICE_PATH`;
  do
    echo "  " $SCRIPT_NAME $item
  done
}

# args: SERVICE_NAME, ACTION
invoke_service()
{
  SERVICE_NAME=$1
  ACTION=$2
  unset PACKAGE_LIST
  unset SERVICE_LIST
  load_file "${SERVICE_PATH}/$SERVICE_NAME"
  SET_PACKAGE_LIST=$PACKAGE_LIST
  SET_SERVICE_LIST=$SERVICE_LIST
  if [ -z "$ACTION" ]; then
    echo "$SERVICE_NAME Support actions:"
    echo -n "  "
    if [ ! -z "$SERVICE_LIST" ]; then
      echo -n "start stop restart "
    fi
    echo_usable_action "config clean install download uninstall"
    echo " "
    return
  fi
  echo "${ACTION}: ${SERVICE_NAME}"
  if [ ! -z "$SET_SERVICE_LIST" ] && [ "start" = $ACTION -o "stop" = $ACTION -o "restart" = $ACTION  ]; then
    if is_usable "$INVOKE$SERVICE_NAME"_service; then
      "$INVOKE$SERVICE_NAME"_service $ACTION
    else
      func_service $ACTION
    fi
  elif is_usable "$INVOKE$SERVICE_NAME"_"$ACTION"; then
    $INVOKE$SERVICE_NAME"_"$ACTION
  elif is_usable "$INVOKE$ACTION"; then
    $INVOKE$ACTION
  else
    echo "$SERVICE_NAME: '$ACTION' Not Implement"
  fi
}

if [ $# -le 0 ]; then
  help
elif [ -e "${SERVICE_PATH}/$1" ]; then
  load_file $CONFIG_FILE
  load_file $SERVICE_FILE
  invoke_service $1 $2
else
  echo "$1 not found..."
  exit 1
fi
