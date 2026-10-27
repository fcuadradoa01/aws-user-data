#!/bin/bash

# Log de instalación
exec > /var/log/user-data.log 2>&1

# Variables
DB_NAME="wordpress"
DB_USER="wordpress"
DB_PASS="P@ssword"
WP_DIR="/var/www/html"

# Actualizar sistema
apt update -y
apt upgrade -y

# Instalar Apache, MariaDB y PHP
DEBIAN_FRONTEND=noninteractive apt install -y \
apache2 \
mariadb-server \
php \
php-mysql \
php-cli \
php-curl \
php-gd \
php-mbstring \
php-xml \
php-xmlrpc \
php-soap \
php-intl \
php-zip \
wget \
unzip

# Arrancar servicios
systemctl enable apache2
systemctl enable mariadb
systemctl start apache2
systemctl start mariadb

# Crear BD y usuario WordPress
mysql <<EOF
CREATE DATABASE ${DB_NAME};
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

# Limpiar directorio web
rm -rf ${WP_DIR}/*

# Descargar WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# Copiar WordPress
cp -R wordpress/* ${WP_DIR}/

# Permisos
chown -R www-data:www-data ${WP_DIR}
find ${WP_DIR} -type d -exec chmod 755 {} \;
find ${WP_DIR} -type f -exec chmod 644 {} \;

# Configuración WordPress
cp ${WP_DIR}/wp-config-sample.php ${WP_DIR}/wp-config.php

sed -i "s/database_name_here/${DB_NAME}/" ${WP_DIR}/wp-config.php
sed -i "s/username_here/${DB_USER}/" ${WP_DIR}/wp-config.php
sed -i "s/password_here/${DB_PASS}/" ${WP_DIR}/wp-config.php

# Reiniciar Apache
systemctl restart apache2
