#!/bin/bash
SCRIPT_NAME=all-shit.sh
MAIN_SCRIPT=openshit.sh
PREINSTALL_SCRIPT=pre-install.sh

#services
SERVICE_DATABASE=mysql
SERVICE_MESSAGE_QUEUE=rabbitmq
SERVICE_OPENSTACK_IDENTITY=keystone
SERVICE_OPENSTACK_IMAGE=glance
SERVICE_OPENSTACK_COMPUTE=nova
SERVICE_OPENSTACK_BLOCK_STORAGE=cinder
SERVICE_OPENSTACK_NETWORK=nova-network
SERVICE_OPENSTACK_DASHBOARD=dashboard

#service list
SERVICES="\
  $SERVICE_DATABASE \
  $SERVICE_MESSAGE_QUEUE \
  $SERVICE_OPENSTACK_IDENTITY \
  $SERVICE_OPENSTACK_IMAGE \
  $SERVICE_OPENSTACK_COMPUTE \
  $SERVICE_OPENSTACK_BLOCK_STORAGE \
  $SERVICE_OPENSTACK_NETWORK \
  "

SERVICE_HAS_DATABASE="\
  $SERVICE_OPENSTACK_IDENTITY \
  $SERVICE_OPENSTACK_IMAGE \
  $SERVICE_OPENSTACK_COMPUTE \
  $SERVICE_OPENSTACK_BLOCK_STORAGE \
  "

COMPONENTS="\
  $SERVICE_OPENSTACK_DASHBOARD
  "

# args: service-list
# env: ACTION

ACTION=""
run_openshit()
{
  local LIST=$@
  for SERVICE in $LIST;
  do
    echo "${ACTION}: ${SERVICE}"
    source $MAIN_SCRIPT $SERVICE $ACTION
  done
}

help()
{
  echo "usage: ${SCRIPT_NAME} <start|stop|restart|config|clean|install|download|uninstall>"
}

if [ $# -lt 1 ]; then
  help
  exit
fi
ACTION=$1
if [ $ACTION = "start" -o $ACTION = "stop" -o $ACTION = "restart" ]; then
  run_openshit $SERVICES
elif [ $ACTION = "config" ]; then
  run_openshit $SERVICES
elif [ $ACTION = "clean" ]; then
  run_openshit $SERVICE_HAS_DATABASE
elif [ $ACTION = "install" -o $ACTION = "download" ]; then
  read -p "Do you need configure your soft-source before install/download? [Y/n]" ret
  if [ -z $ret -o 'Y' = $ret -o 'y' = $ret ]; then
    bash $PREINSTALL_SCRIPT
  fi
  run_openshit $SERVICES
  run_openshit $COMPONENTS
elif [ $ACTION = "uninstall" ]; then
  run_openshit $SERVICES
  run_openshit $COMPONENTS
else
  help
fi
