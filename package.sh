#!/bin/sh
DEPENDENCE_LIST=dependence-pack.list
OPENSTACK_LIST=openstack-package.list
SCRIPT_NAME=package.sh

do_checkfile()
{
  if [ ! -f "$DEPENDENCE_LIST" ]; then
    echo error: $DEPENDENCE_LIST not found
    exit 1
  fi
  echo Loading $DEPENDENCE_LIST ..

  if [ ! -f "$OPENSTACK_LIST" ]; then
    echo error: $OPENSTACK_LIST not found
    exit 1
  fi
  echo Loading $OPENSTACK_LIST ..
}
do_install()
{
  echo Installing...
  do_checkfile
  cat $DEPENDENCE_LIST | while read line; do sudo apt-get -y install $line; done
  cat $OPENSTACK_LIST | while read line; do sudo apt-get -y install $line; done
}

do_download()
{
  echo Downloading...
  do_checkfile
  cat $DEPENDENCE_LIST | while read line; do sudo apt-get -d install $line; done
  cat $OPENSTACK_LIST | while read line; do sudo apt-get -d install $line; done
}

do_uninstall()
{
  echo Uninstalling...
  do_checkfile
  cat $OPENSTACK_LIST | while read line; do sudo apt-get --purge remove $line; done
  echo "Do you want to REMOVE dependence software package?"
  cat $DEPENDENCE_LIST | xargs echo "   "
  echo "Can not Undo. REMOVE? (Y/N)[default=N]\c"
  line=n
  read line
  if [ ! -n $line ]; then
    if [ "y" = $line -o "Y" = $line ]; then
      cat $DEPENDENCE_LIST | while read line; do sudo apt-get --purge remove $line; done 
    fi
  fi
}

help()
{
  echo "usage: " $SCRIPT_NAME "<download|install|uninstall>"
}

if [ $# -le 0 ]; then
  help
elif [ "download" = $1 ]; then
  do_download
elif [ "install" = $1 ]; then
  do_install
elif [ "uninstall" = $1 ]; then
  do_uninstall
else
  help
fi
