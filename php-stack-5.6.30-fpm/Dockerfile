FROM php:5.6.30-fpm

# RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
# RUN sed -i 's;http://archive.debian.org/debian/;http://deb.debian.org/debian/;' /etc/apt/sources.list

# debian stretch moved to archive.debian.org on 2023-03-27
RUN export DEBIAN_FRONTEND="noninteractive" && \
    echo "deb http://archive.debian.org/debian/ stretch main non-free contrib" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ stretch/updates main non-free contrib" >> /etc/apt/sources.list && \
    apt-get update -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true -o APT::Get::AllowUnauthenticated=true && \
    apt-get install -y --no-install-recommends -o APT::Get::AllowUnauthenticated=true debian-archive-keyring


RUN apt-get update && apt-get install --yes --force-yes \
    libssl-dev \
    libssl-doc \
    libsasl2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpq-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpng12-dev \
    libmemcached-dev \
    zlib1g-dev \
    && docker-php-ext-install -j$(nproc) bz2 iconv mcrypt mbstring pdo_mysql mysql mysqli pgsql pdo_pgsql zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Install xdebug
# RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install MongoDB Client
# RUN pecl install mongodb && docker-php-ext-enable mongodb

# Install Redis Client
# RUN pecl install redis && docker-php-ext-enable redis
