wget -O - http://packages.icinga.org/icinga.key | sudo apt-key add -
add-apt-repository 'deb http://packages.icinga.org/ubuntu icinga-xenial main'
apt-get install icinga2 nagios-plugins -y
sudo systemctl start icinga2
sudo systemctl enable icinga2
sudo systemctl status icinga2
icinga2 node wizard