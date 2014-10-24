# Install Network Time Protocal Service
sudo apt-get -y install ntp

# Install mysql
sudo apt-get -y install mariadb-server python-mysqldb

# Install rabbitmq
sudo apt-get -y install rabbitmq-server

# Install keystone
sudo apt-get -y install keystone python-keystoneclient

# Install glance
sudo apt-get -y install glance python-glanceclient

# Install nova
sudo apt-get -y install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient

# Install nova-compute
sudo apt-get -y install nova-compute

# Install nova-network
sudo apt-get -y install nova-network

# Install dashboard
sudo apt-get -y install openstack-dashboard apache2 libapache2-mod-wsgi memcached python-memcache

# Install cinder
sudo apt-get -y install cinder-api cinder-scheduler python-cinderclient

# Install cinder-volume
sudo apt-get -y install cinder-volume python-mysqldb
