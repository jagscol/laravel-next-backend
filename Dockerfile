FROM php:8.1-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG gid=1000

RUN userdel -f www-data &&\
  if getent group www-data ; then groupdel www-data; fi &&\
  groupadd -g ${uid} www-data &&\
  useradd -l -u ${gid} -g www-data www-data &&\
  install -d -m 0755 -o www-data -g www-data /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git \
  curl \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  zip \
  libzip-dev \
  unzip \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-configure zip \
  && docker-php-ext-install zip \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug

# Development
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

COPY ./docker/app/conf/php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf

# Get latest Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install NodeJs
RUN apt-get update && \
  apt-get install -y wget && \
  apt-get install -y gnupg2 && \
  wget -qO- https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get install -y build-essential nodejs
# End Install

# Create system user to run Composer and Artisan Commands

# Set working directory
WORKDIR /var/www/app

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
