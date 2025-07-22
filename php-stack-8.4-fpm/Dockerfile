FROM php:8.4-fpm
LABEL maintainer="docker-webstack"
LABEL description="PHP 8.4 FPM optimized for Laravel with comprehensive extensions"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LOCALTIME=Asia/Kuala_Lumpur \
    PHPFPM__access.format='"%R - %u [%t] \"%m %r\" %s %l %Q %f"'

# Install system dependencies for Laravel
RUN apt-get update && apt-get install -y \
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
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
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
# RUN pecl install redis-6.0.2 \
#     && docker-php-ext-enable redis

# Install Xdebug for PHP 8.4
RUN pecl install xdebug-3.4.0 \
    && docker-php-ext-enable xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

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
