#!/bin/sh

echo "
########################################################################

 ____                         _ 
|  _ \ _ __ _   _ _ __   __ _| |
| | | | '__| | | | '_ \ / _' | |
| |_| | |  | |_| | |_) | (_| | |
|____/|_|   \__,_| .__/ \__,_|_|
                 |_|            
 _____            _                                      _   
| ____|_ ____   _(_)_ __ ___  _ __  _ __ ___   ___ _ __ | |_ 
|  _| | '_ \ \ / / | '__/ _ \| '_ \| '_ ' _ \ / _ \ '_ \| __|
| |___| | | \ V /| | | | (_) | | | | | | | | |  __/ | | | |_ 
|_____|_| |_|\_/ |_|_|  \___/|_| |_|_| |_| |_|\___|_| |_|\__|
                                                             
A Vagrant development environment container for Drupal projects.

MySQL root password: vagrant
Drupal site: derp


########################################################################
"


# Update and upgrade
echo "Updating system..."
apt-get update > /dev/null 2>&1
echo "Upgrading system packages..."
apt-get -y upgrade > /dev/null 2>&1

# Pre-config mysql
echo "Preconfig for MySQL: "
echo "mysql-server mysql-server/root_password password vagrant" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password vagrant" | debconf-set-selections
echo "Done."

# Install system dependencies.
echo "Installing system dependencies: "
apt-get -y install git php5 php5-mysql php5-gd mysql-server > /dev/null 2>&1
echo "Done."

echo "Configuring MySQL with user: vagrant, pass: vagrant, db name: vagrant: "
mysql -uroot -pvagrant -e "create database derp; grant all privileges on derp.* to 'vagrant'@'%' identified by 'vagrant'; flush privileges;"
echo "Done."

echo "Installing composer: "
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /usr/bin/composer
echo "Done."

echo "Installing drush: "
# composer global require drush/drush:6.*
git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
cd /usr/local/src/drush
git checkout 6.5.0 > /dev/null 2>&1
ln -s /usr/local/src/drush/drush /usr/bin/drush
composer install
drush --version
echo "Done."

# todo, clean this up
echo "Configure (derp) drupal site: "
cd /vagrant
if [ ! -d /vagrant/derp ]; then
	drush dl drupal --drupal-project-rename=derp
fi
cd derp
drush site-install standard --db-url='mysql://vagrant:vagrant@localhost/derp' --site-name=Derp --account-name=admin --account-pass=vagrant -y
rm -rf /var/www/html
ln -s /vagrant/derp /var/www/html
echo "Done"

echo "Finished!  Please visit http://localhost:9000/ and sign in with admin / vagrant."