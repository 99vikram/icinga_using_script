sudo apt-get update
sudo dpkg -l selinux*
sudo add-apt-repository ppa:ondrej/php
sudo apt-get install apache2 -y
sudo apt-get install wget build-essential  php apache2-mod-php7.0 php-gd libgd-dev unzip -y
sudo apt-get install autoconf gcc libc6 make wget unzip libapache2-mod-php7.2 libgd-dev -y
sudo apt-get -f install -y
sudo systemctl start apache2
sudo systemctl enable apache2

useradd nagios
groupadd nagcmd
usermod -a -G nagios,nagcmd www-data
sudo a2enmod rewrite
sudo a2enmod cgi

cd /tmp
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.4.1.tar.gz
wget http://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz
tar zxvf nagios-4.4.1.tar.gz
tar zxvf nagios-plugins-2.1.2.tar.gz 
cd nagios-4.4.1
./configure --with-command-group=nagcmd -–with-mail=/usr/bin/sendmail --with-httpd-conf=/etc/apache2/sites-enabled

make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
make install-daemoninit

cd /tmp/nagios-plugins-2.1.2
./configure --with-nagios-user=nagios --with-nagios-group=nagios
Make
make install

sudo update-rc.d nagios defaults
sudo systemctl start nagios

htpasswd –c /usr/local/nagios/etc/htpasswd.users nagiosadmin
cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

sudo ufw allow Apache
sudo ufw reload
sudo systemctl restart apache2.service
sudo systemctl start nagios.service


git clone https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz
tar zxf nrpe-*.tar.gz
cd nrpe-*
Sudo apt-get install libssl-dev
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
sudo make install
sudo make install-config
sudo make install-init
sudo systemctl start nrpe.service
sudo ufw allow 5666/tcp  
sudo systemctl status nrpe.service

sudo systemctl start nagios.service
sudo systemctl stop nagios.service
sudo systemctl restart nagios.service
sudo systemctl status nagios.service
