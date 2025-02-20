FROM php:8.2-fpm-alpine

# Install PHP and composer dependencies
RUN set -xe \
    && apk add --update \
        icu \
    && apk add --no-cache --virtual .php-deps \
        make \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++ \
        php-pgsql \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
        intl pdo_mysql \
    && docker-php-ext-enable intl \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && apk del .build-deps \
    && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* 

    
RUN apk add --no-cache postgresql-client postgresql-dev \
    && docker-php-ext-configure pgsql \
    && docker-php-ext-install pgsql


# Install needed PECL extensions
RUN pecl config-set php_ini "${PHP_INI_DIR}/php.ini"

# Install Xdebug
# RUN pecl install xdebug && docker-php-ext-enable xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer global require laravel/installer
