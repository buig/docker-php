FROM php:7.2-apache

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

#PHP INSTALLATION
RUN apt-get update && apt-get install -y \
    git \
    gnupg \
    libjpeg-dev \
    libldap2-dev \
    libpng-dev \
    libxml2-dev \
    tmux \
    vim \
    zip \
    zlib1g-dev \
    default-mysql-client

# Imagick
RUN apt-get install -y libmagickwand-dev --no-install-recommends
RUN pecl install imagick-beta
RUN docker-php-ext-enable imagick

RUN docker-php-ext-configure gd --with-png-dir=/usr/lib/ --with-jpeg-dir=/usr/lib/ --with-gd
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-configure intl

RUN docker-php-ext-install \
    gd \
    ldap \
    mysqli \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    soap \
    zip \
    intl \
    exif

# Install xDebug
RUN pecl install xdebug
#RUN docker-php-ext-enable xdebug

# Install opcache
RUN docker-php-ext-install opcache

# Install APCu
RUN pecl install apcu
RUN echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini

RUN echo "memory_limit=-1" > /usr/local/etc/php/conf.d/memory-limit-php.ini

WORKDIR /code

#Composer installation
RUN curl -o composer-setup.php https://getcomposer.org/installer && \
    curl -o composer-setup.sig https://composer.github.io/installer.sig && \
    php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) !== trim(file_get_contents('composer-setup.sig'))) { unlink('composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" && \
    php composer-setup.php --version=1.10.16 --quiet && \
    mv composer.phar /usr/local/bin/composer

#APACHE INTALLATION
RUN a2enmod rewrite headers