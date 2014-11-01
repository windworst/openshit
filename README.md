**OpenShit, OpenStack HITter**

__An Open Stack Configurer__

support ubuntu 14.04 (server/desktop)

**Usage:**

    openshit.sh <Service_Name> [Action]

  **For example**

    ./openshit.sh --all
    ./openshit.sh cinder
    ./openshit.sh dashboard
    ./openshit.sh glance
    ./openshit.sh keystone
    ./openshit.sh mysql
    ./openshit.sh neutron
    ./openshit.sh nova
    ./openshit.sh nova-network
    ./openshit.sh rabbitmq

  **install & configure Openstack**

    vim setting.conf # edit your setting. like password, ipaddress, net-card

    ./openshit.sh --all install && ./openshit.sh --all config

  **clean & uninstall**

    ./openshit.sh --all clean && ./openshit.sh --all uninstall

