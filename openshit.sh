#!/bin/bash
SCRIPT_NAME=openshit.sh
CONFIG_FILE=setting.conf
SERVICE_FILE=service.conf
SERVICE_PATH=services
SERVICE_ENV_FILE=service-env.sh
ADMIN_ENV_FILE=admin-env.sh
PRE_INSTALL_FILE=pre-install.sh
CONFIG_EDITOR=conf_editor.py

CONFIG_ROLLBACK_SCRIPT=rollback.sh
if [ -z "$CONFIG_BAK_PATH" ]; then
  export CONFIG_BAK_PATH="config-backups/"$(date "+%Y-%m-%d_%H,%M,%S")
fi

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

# args: FILE_NAME
import()
{
  load_file $SERVICE_PATH/$1
}

load_admin_env()
{
  load_file $ADMIN_ENV_FILE
}

load_service_env()
{
  load_file $SERVICE_ENV_FILE
}

# args: file_path function_name arg1 arg2 ....
edit_config_file()
{
  local FILE_PATH=$1
  local FUNC_NAME=$2
  local FILE_NAME=${FILE_PATH##*/}
  local BAK_FILE_NAME=$FILE_NAME"-"$(date "+%Y-%m-%d_%H,%M,%S")

  mkdir -p $CONFIG_BAK_PATH &>/dev/null

  shift 2
  echo "Configuring $FILE_PATH ..."
  if sudo cp $FILE_PATH $CONFIG_BAK_PATH/$BAK_FILE_NAME && $FUNC_NAME $@ \
    | sudo python $CONFIG_EDITOR $CONFIG_BAK_PATH/$BAK_FILE_NAME | sudo tee $FILE_PATH &>/dev/null; then

    #set roll-back script
    local ROLL_BACK_TMP=$CONFIG_ROLLBACK_SCRIPT".tmp"
    mv $CONFIG_BAK_PATH/$CONFIG_ROLLBACK_SCRIPT $CONFIG_BAK_PATH/$ROLL_BACK_TMP 2> /dev/null
    echo "sudo cp $BAK_FILE_NAME $FILE_PATH" > $CONFIG_BAK_PATH/$CONFIG_ROLLBACK_SCRIPT
    cat $CONFIG_BAK_PATH/$ROLL_BACK_TMP >> $CONFIG_BAK_PATH/$CONFIG_ROLLBACK_SCRIPT 2>/dev/null
    chmod a+x $CONFIG_BAK_PATH/$CONFIG_ROLLBACK_SCRIPT
    rm -f $CONFIG_BAK_PATH/$ROLL_BACK_TMP
  fi
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
  sudo apt-get -y autoremove
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
    if is_usable $INVOKE$item || is_usable "$INVOKE$SERVICE_NAME"_"$item"; then
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
  load_file $SERVICE_FILE
  load_file $CONFIG_FILE
  invoke_service $1 $2
else
  echo "$1 not found..."
  exit 1
fi
