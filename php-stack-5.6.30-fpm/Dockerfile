FROM php:5.6.30-fpm
LABEL maintainer="docker-webstack"
LABEL description="PHP 5.6 FPM optimized for Laravel with comprehensive extensions"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LOCALTIME=Asia/Kuala_Lumpur \
    PHPFPM__access.format='"%R - %u [%t] \"%m %r\" %s %l %Q %f"'

# Configure Debian repositories for archived versions
RUN echo "deb http://archive.debian.org/debian/ stretch main non-free contrib" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ stretch/updates main non-free contrib" >> /etc/apt/sources.list && \
    apt-get update -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true -o APT::Get::AllowUnauthenticated=true && \
    apt-get install -y --no-install-recommends -o APT::Get::AllowUnauthenticated=true debian-archive-keyring

# Install system dependencies for Laravel
RUN apt-get update && apt-get install --yes --force-yes \
    # Core libraries
    libssl-dev \
    libssl-doc \
    libsasl2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpq-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libpng-dev \
    libmemcached-dev \
    zlib1g-dev \
    # Additional libraries for Laravel
    libicu-dev \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libbz2-dev \
    libjpeg-dev \
    libonig-dev \
    libreadline-dev \
    # System utilities
    git \
    unzip \
    vim \
    curl \
    wget \
    supervisor \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Fix curl headers issue for PHP 5.6
RUN ln -sf /usr/include/x86_64-linux-gnu/curl /usr/include/curl

# Install PHP extensions for Laravel
RUN docker-php-ext-install -j$(nproc) \
    # Core extensions
    bz2 \
    iconv \
    mcrypt \
    mbstring \
    # Database extensions
    pdo_mysql \
    mysql \
    mysqli \
    pgsql \
    pdo_pgsql \
    # Laravel essentials
    zip \
    xml \
    curl \
    json \
    tokenizer \
    fileinfo \
    bcmath \
    calendar \
    exif \
    gettext \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm

# Configure and install GD extension
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Configure and install Intl extension
RUN docker-php-ext-configure intl && docker-php-ext-install intl

# Install PECL extensions
RUN pecl install \
    redis-3.1.6 \
    memcached-2.2.0 \
    imagick-3.4.4 \
    xdebug-2.5.5 \
    && docker-php-ext-enable redis memcached imagick xdebug

# Configure Xdebug for development (PHP 5.6 compatible)
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_log=/var/log/php/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install Composer (latest version compatible with PHP 5.6)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.26

# Node.js removed - not needed for PHP 5.6 container

# Set working directory
WORKDIR /var/www/projects

# Configure www-data user for consistency
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Create directories with proper permissions for PHP-FPM
RUN mkdir -p /var/log/php /tmp/sessions /tmp/uploads /var/run/php-fpm /usr/local/var/log \
    && chown -R www-data:www-data /var/log/php /tmp/sessions /tmp/uploads /var/run/php-fpm /usr/local/var/log \
    && chmod 755 /var/log/php /var/run/php-fpm /usr/local/var/log \
    && chmod 1777 /tmp/sessions /tmp/uploads

# Change current user to www-data
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm", "--nodaemonize"]
