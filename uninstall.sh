# Uninstall keystone
sudo apt-get --purge remove keystone python-keystoneclient

# Uninstall glance
sudo apt-get --purge remove glance python-glanceclient

# Uninstall nova
sudo apt-get --purge remove nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient

# Uninstall nova-compute
sudo apt-get --purge remove nova-compute

# Uninstall nova-network
sudo apt-get --purge remove nova-network

# Uninstall dashboard
sudo apt-get --purge remove openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache

# Uninstall cinder
sudo apt-get --purge remove cinder-api cinder-scheduler python-cinderclient

# Uninstall cinder-volume
sudo apt-get --purge remove cinder-volume python-mysqldb

echo "Do you want to remove Mysql, Ntp, Rabbitmq? ( Ctrl+C Cancel )"
read
echo "Are you sure?"
read

# Uninstall Network Time Protocal Service
sudo apt-get --purge remove ntp

# Uninstall mysql
sudo apt-get --purge remove mariadb-server python-mysqldb

# Uninstall rabbitmq
sudo apt-get --purge remove rabbitmq-server

sudo apt-get autoremove
