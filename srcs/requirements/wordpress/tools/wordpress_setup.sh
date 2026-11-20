#!/bin/bash

cd /var/www/html

while ! mariadb-admin ping -h"mariadb" --silent; do
    echo "In attesa di MariaDB..."
    sleep 2
done

if [ ! -f wp-config.php ]; then

    rm -rf /var/www/html/*

    wp core download --allow-root --force --path=/var/www/html

    wp config create \
        --dbname=${WORDPRESS_DB_NAME} \
        --dbuser=${WORDPRESS_DB_USER} \
        --dbpass=${WORDPRESS_DB_PASSWORD} \
        --dbhost=${WORDPRESS_DB_HOST} \
        --allow-root

    wp core install \
        --url=${DOMAIN_NAME} \
        --title="Progetto Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root

    wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root

    chown -R www-data:www-data /var/www/html
fi

exec /usr/sbin/php-fpm8.2 -F