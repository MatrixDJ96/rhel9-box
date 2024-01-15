#!/bin/bash

cd "${HOME}" || exit

echo "Configuring repositories..."
bash --login /vagrant/config/provision/yum.sh

echo "Installing basic packages..."
bash --login /vagrant/config/provision/basic_packages.sh

echo "Installing/Configuring SELinux..."
bash --login /vagrant/config/provision/selinux.sh

echo "Installing/Configuring SSH..."
bash --login /vagrant/config/provision/ssh.sh

echo "Installing/Configuring Apache..."
bash --login /vagrant/config/provision/apache.sh

echo "Installing/Configuring MySQL..."
bash --login /vagrant/config/provision/mysql.sh

echo "Installing/Configuring PHP..."
bash --login /vagrant/config/provision/php.sh

echo "Installing/Configuring Composer..."
bash --login /vagrant/config/provision/composer.sh

echo "Installing/Configuring Mise..."
bash --login /vagrant/config/provision/mise.sh

echo "Installing/Configuring Nodejs..."
bash --login /vagrant/config/provision/nodejs.sh

echo "Installing/Configuring Java..."
bash --login /vagrant/config/provision/java.sh

echo "Installing/Configuring Tomcat..."
bash --login /vagrant/config/provision/tomcat.sh

echo "Installing/Configuring Keycloak..."
bash --login /vagrant/config/provision/keycloak.sh

echo "Installing/Configuring Mercure..."
bash --login /vagrant/config/provision/mercure.sh

echo "Installing extra packages..."
bash --login /vagrant/config/provision/extra_packages.sh

echo "Updating system packages..."
bash --login /vagrant/config/provision/update.sh

echo "Cleaning system files..."
bash --login /vagrant/config/provision/clean.sh

echo "Installation completed!"
