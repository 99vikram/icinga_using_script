#!/bin/sh
sudo apt-get update 
sudo apt-get install apache2 -y
sudo apt-get install php7.0 libapache2-mod-php7.0 php7.0-gd php7.0-intl php7.0-xml php7.0-ldap php7.0-mysql php7.0-pgsql php-imagick zip unzip icingaweb2 icingaweb2-module-monitoring icingaweb2-module-doc mariadb-client mariadb-server  -y
sudo apt-get -f install -y
wget -O - http://packages.icinga.org/icinga.key | sudo apt-key add -
sudo add-apt-repository 'deb http://packages.icinga.org/ubuntu icinga-xenial main'

sudo apt-get update
sudo apt-get install icinga2 nagios-plugins icinga2-ido-mysql -y

sudo systemctl start apache2.service
sudo systemctl enable apache2.service
sudo systemctl start mysql.service
sudo systemctl enable mysql.service
sudo systemctl start icinga2.service
sudo systemctl enable icinga2.service

sudo groupadd icingacmd
sudo usermod -a -G icingacmd www-data
id www-data

sudo icingacli setup config webserver apache --document-root /usr/share/icingaweb2/public
sudo systemctl restart apache2.service

sudo icinga2 feature enable ido-mysql
sudo systemctl restart icinga2.service

sudo sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/" /etc/apache2/apache2.conf

sudo ufw app list
sudo ufw allow OpenSSH
sudo ufw allow in "Apache Full"

sudo /usr/bin/mysql_secure_installation
#root
#Enter current password for root (enter for none): Enter
#Set root password? [Y/n]: Y
#New password: <your-password>
#Re-enter new password: <your-password>
#Remove anonymous users? [Y/n]: Y
#Disallow root login remotely? [Y/n]: Y
#Remove test database and access to it? [Y/n]: Y
#Reload privilege tables now? [Y/n]: Y
pass="root"
sudo mysql -u root -p${pass} -e "UPDATE mysql.user SET authentication_string=PASSWORD('root'), plugin='mysql_native_password' WHERE user='root';FLUSH PRIVILEGES;"
sudo mysql -u root -p${pass} -e "CREATE DATABASE icinga;GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX, EXECUTE ON icinga.* TO 'icinga'@'localhost' IDENTIFIED BY 'icinga';FLUSH PRIVILEGES;"
sudo mysql -u root -p${pass} icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
sudo mysql -u root -p${pass} -e "CREATE DATABASE icingaweb2;"
mysql -u root -p${pass} icingaweb2 < /usr/share/icingaweb2/etc/schema/mysql.schema.sql

sudo echo "date.timezone = Asia/Kolkata" >>  /etc/php/7.0/apache2/php.ini
sudo systemctl restart apache2.service

sudo vi /etc/icinga2/features-available/ido-mysql.conf

sudo systemctl restart icinga2.service
sudo systemctl restart apache2.service

sudo apt-get install make rrdtool librrds-perl g++ -y
cd /tmp
wget http://downloads.sourceforge.net/project/pnp4nagios/PNP-0.6/pnp4nagios-0.6.26.tar.gz
tar -zxf pnp4nagios-0.6.26.tar.gz
cd pnp4nagios-0.6.26/
./configure --with-nagios-user=naemon --with-nagios-group=naemon
make all
make install
make install-webconf
make install-config
make install-init

useradd naemon
groupadd naemon
usermod -a -G naemon naemon

update-rc.d npcd defaults
service npcd start

icinga2 node wizard
sudo systemctl restart icinga2

sudo mkdir /etc/icinga2/zones.d/master/
cp /etc/icinga2/conf.d/templates.conf /etc/icinga2/zones.d/master/
cp /etc/icinga2/conf.d/commands.conf /etc/icinga2/zones.d/master/

cd /etc/icinga2/zones.d/master
touch /etc/icinga2/zones.d/master/services.conf
echo "apply Service "load" {
  import "generic-service"
  check_command = "load"
  command_endpoint = host.vars.client_endpoint
  assign where host.vars.client_endpoint
}
apply Service "ping4" {
  import "generic-service"
  check_command = "ping4"
  command_endpoint = host.vars.client_endpoint
  assign where host.vars.client_endpoint
}
apply Service "disk" {
  import "generic-service"
  check_command = "disk"
  command_endpoint = host.vars.client_endpoint
  assign where host.vars.client_endpoint
}

apply Service "mem" {
  import "generic-service"
  check_command = "mem"
  command_endpoint = host.vars.client_endpoint
  assign where host.vars.client_endpoint
}
apply Service "procs" {
  import "generic-service"
  check_command = "procs"
  command_endpoint = host.vars.client_endpoint
  assign where host.vars.client_endpoint
}" > /etc/icinga2/zones.d/master/services.conf

sudo systemctl restart icinga2
sudo ufw allow 5665
sudo icinga2 daemon --validate
sudo icingacli setup token create
sudo vim /usr/share/icinga2/include/plugins-contrib.d/operating-system.conf
sudo df -h
netstat | grep :5665
#sudo vi /etc/icinga2/features-available/ido-mysql.conf
#user = "icinga"
#password = "icinga"
#host = "localhost"
#database = "icinga"
