FROM php:7.2-fpm
LABEL maintainer="docker-webstack"
LABEL description="PHP 7.2 FPM optimized for Laravel with comprehensive extensions"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LOCALTIME=Asia/Kuala_Lumpur \
    PHPFPM__access.format='"%R - %u [%t] \"%m %r\" %s %l %Q %f"'

# Configure archive repositories for Debian Buster
RUN echo "deb http://archive.debian.org/debian/ buster main non-free contrib" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ buster/updates main non-free contrib" >> /etc/apt/sources.list && \
    apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --allow-unauthenticated \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    opcache \
    mysqli

# Install Redis extension
RUN pecl install redis-5.3.4 \
    && docker-php-ext-enable redis

# Install Xdebug for PHP 7.2
RUN pecl install xdebug-2.9.8 \
    && docker-php-ext-enable xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=2.2.24

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
