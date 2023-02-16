FROM php:8.0-fpm-buster 
# guna buster utk debian 10. driver mssql msodbcsql17 xda lagi untuk debian 11 ( bulleye )
MAINTAINER Muhamad Hanafiah Yahya <ibnuyahya@gmail.com>

RUN apt-get update && \
    apt-get install -y \
    freetds-bin \
    freetds-dev \
    freetds-common \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    gnupg2 \
    && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen 

RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install bcmath  

#RUN docker-php-ext-configure pdo_dblib --with-libdir=lib/x86_64-linux-gnu && \
#    docker-php-ext-install pdo_dblib

# Install the Microsoft ODBC driver for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update  \
    && ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17 unixodbc-dev=2.3.7 unixodbc=2.3.7 odbcinst1debian2=2.3.7 odbcinst=2.3.7 \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc 

# Install pdo sqlsrv
RUN pecl config-set php_ini /usr/local/etc/php/conf.d/php.ini \
    && pecl install sqlsrv \
    && pecl install pdo_sqlsrv \
    && echo 'extension=sqlsrv.so' >> /usr/local/etc/php/conf.d/sqlsrv.ini \
    && echo 'extension=pdo_sqlsrv.so' >> /usr/local/etc/php/conf.d/sqlsrv.ini 

# Zip
RUN docker-php-ext-install zip

# remove list
RUN rm -rf /var/lib/apt/lists/*

# GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg 
RUN docker-php-ext-install gd

# install xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

# RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.default_enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.profiler_enable=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# RUN echo "xdebug.remote_log=\"/tmp/xdebug.log\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini



ENV LOCALTIME Asia/Kuala_Lumpur
ENV PHPFPM__access.format '"%R - %u [%t] \"%m %r\" %s %l %Q %f"'

WORKDIR /var/www

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


### Special modifications for the www-data user.

# RUN groupadd -og 999 docker && usermod -a -G docker www-data

# Add www-data environment (for SSH mostly)
# RUN sed -i 's/\#umask 022/umask 002/' /etc/skel/.profile
# RUN usermod -d /home/www-data -s /bin/bash www-data \
#    && cp -av /etc/skel /home/www-data \
#    && mv /var/www /home/www-data/www \
#    && ln -s /home/www-data/www /var/www \
#    && chown -R www-data:www-data /home/www-data


