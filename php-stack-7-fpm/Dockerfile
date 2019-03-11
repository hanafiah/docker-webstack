FROM php:7.1-fpm

RUN apt-get update && apt-get install -y \
    libmcrypt-dev \
    mysql-client libmagickwand-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) mcrypt pdo_mysql mysqli gd fileinfo ctype bcmath mbstring

RUN pecl install mongodb && docker-php-ext-enable mongodb
