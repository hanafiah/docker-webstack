#!/bin/bash
set -e

# Ensure PID directory exists and has correct permissions
mkdir -p /var/run/php-fpm
chown www-data:www-data /var/run/php-fpm
chmod 755 /var/run/php-fpm

# Switch to www-data user and execute PHP-FPM
exec su www-data -c "docker-php-entrypoint $*"
