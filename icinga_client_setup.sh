cd /tmp
wget -O - http://packages.icinga.org/icinga.key | sudo apt-key add -
sudo add-apt-repository 'deb http://packages.icinga.org/ubuntu icinga-bionic main'
sudo apt-get update
sudo apt-get install icinga2 nagios-plugins -y
sudo apt-get install apache2 -y

sudo systemctl start icinga2
sudo systemctl enable icinga2
sudo systemctl status icinga2
icinga2 node wizard

sudo ufw allow 5665
sudo ufw allow apache2
sudo systemctl restart icinga2
netstat | grep :5665

cd /usr/lib/nagios/plugins
git clone https://github.com/justintime/nagios-plugins.git
cp nagios-plugins/check_mem/check_mem.pl .
rm -rf nagios-plugins/
