FROM php:7.1-fpm
LABEL maintainer="docker-webstack"
LABEL description="PHP 7.1 FPM optimized for Laravel with comprehensive extensions"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LOCALTIME=Asia/Kuala_Lumpur \
    PHPFPM__access.format='"%R - %u [%t] \"%m %r\" %s %l %Q %f"'

# Configure archive repositories for Debian Stretch
RUN echo "deb http://archive.debian.org/debian/ stretch main non-free contrib" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ stretch/updates main non-free contrib" >> /etc/apt/sources.list && \
    apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --allow-unauthenticated \
    curl \
    zip \
    unzip \
    git \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pcntl \
        bcmath \
        opcache \
        mysqli

# Install Redis extension
RUN pecl install redis-4.3.0 \
    && docker-php-ext-enable redis

# Install Xdebug for PHP 7.1
RUN pecl install xdebug-2.8.1 \
    && docker-php-ext-enable xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.26

# Set working directory
WORKDIR /var/www/projects

# Configure www-data user for consistency
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Create directories with proper permissions for PHP-FPM
RUN mkdir -p /var/log/php /tmp/sessions /tmp/uploads /var/run/php-fpm \
    && chown -R www-data:www-data /var/log/php /tmp/sessions /tmp/uploads /var/run/php-fpm \
    && chmod 755 /var/log/php /var/run/php-fpm \
    && chmod 1777 /tmp/sessions /tmp/uploads

# Copy ownership to www-data user
COPY --chown=www-data:www-data . /var/www/projects

# Change current user to www-data
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
