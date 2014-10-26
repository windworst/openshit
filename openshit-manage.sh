#!/bin/bash
SCRIPT_NAME=openshit-manage.sh
CONFIG_FILE=openshit.conf
SERVICE_PATH=service

do_export()
{
  if [ ! -e $CONFIG_FILE ]; then
    echo "$CONFIG_FILE not exsit"
    exit 1
  fi

  echo "Loading..configuration"
  source $CONFIG_FILE
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
elif [ -e "$SERVICE_PATH/"$1 ]; then
  do_export
  source "$SERVICE_PATH/"$1 $@
else
  help
fi
