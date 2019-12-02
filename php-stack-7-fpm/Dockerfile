FROM php:7.1-fpm
MAINTAINER Muhamad Hanafiah Yahya <ibnuyahya@gmail.com>

RUN apt-get update && \
    apt-get install -y --no-install-recommends  pkg-config patch \    
    freetds-bin \
    freetds-dev \
    freetds-common \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen 

RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli  

RUN docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd mbstring exif

RUN docker-php-ext-configure pdo_dblib --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install pdo_dblib

RUN pecl install mongodb && docker-php-ext-enable mongodb    

# remove list
RUN rm -rf /var/lib/apt/lists/*


ENV LOCALTIME Asia/Kuala_Lumpur
ENV PHPFPM__access.format '"%R - %u [%t] \"%m %r\" %s %l %Q %f"'

WORKDIR /var/www




### Special modifications for the www-data user.

RUN groupadd -og 999 docker && usermod -a -G docker www-data

# Add www-data environment (for SSH mostly)
RUN sed -i 's/\#umask 022/umask 002/' /etc/skel/.profile
RUN usermod -d /home/www-data -s /bin/bash www-data \
    && cp -av /etc/skel /home/www-data \
    && mv /var/www /home/www-data/www \
    && ln -s /home/www-data/www /var/www \
    && chown -R www-data:www-data /home/www-data
    

