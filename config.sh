#!/bin/bash
SCRIPT_NAME=config.sh
CONFIG_FILE=openshit.conf

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
  for item in `ls config`;
  do
    echo "  " $SCRIPT_NAME $item
  done
}

if [ $# -le 0 ]; then
  help
elif [ -e "config/"$1 ]; then
  do_export
  source "config/"$1 $@
else
  help
fi
