#!/bin/sh
SCRIPT_NAME=config.sh
CONFIG_INPUT=config.template
CONFIG_OUTPUT=config.list

do_set()
{
  rm -rf $CONFIG_OUTPUT
  for key in `cat $CONFIG_INPUT`;
  do
    read -p "$key" value
    if [ ! -z $value ]; then
      echo "${key}${value}" >> $CONFIG_OUTPUT
    fi
  done
}

do_list()
{
  echo ""
  cat $CONFIG_OUTPUT
  echo ""
}

if [ -e $CONFIG_OUTPUT ]; then
  do_list
  read -p "Do you want to reset? [Y/n](default=N)" line
  if [ ! -z $line ]; then
    if [ "Y" = $line -o "y" = $line ]; then
      do_set
    fi
  fi
else
  do_set
fi
