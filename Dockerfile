FROM akeb/docker-debian12:latest AS base

ARG PHP_VERSION="8.3"
ENV PHP_VERSION=${PHP_VERSION}

# Используем отдельный образ для получения Composer
FROM composer:latest AS composer_builder

# Финальный образ
FROM base

ARG PHP_VERSION
ENV PHP_VERSION=${PHP_VERSION}

COPY --from=composer_builder /usr/bin/composer /usr/local/bin/composer

COPY php-fpm.conf 00-env.ini root_ca.crt logrotate-php-fpm /tmp/

RUN apt-get update -y --allow-insecure-repositories \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        php${PHP_VERSION}-fpm php${PHP_VERSION}-common \
        php${PHP_VERSION}-bcmath php${PHP_VERSION}-curl php${PHP_VERSION}-dom \
        php${PHP_VERSION}-gd php${PHP_VERSION}-igbinary php${PHP_VERSION}-imagick \
        php${PHP_VERSION}-intl php${PHP_VERSION}-mbstring php${PHP_VERSION}-memcached \
        php${PHP_VERSION}-msgpack php${PHP_VERSION}-mysqli php${PHP_VERSION}-mysqlnd \
        php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-zip php${PHP_VERSION}-redis \
        php${PHP_VERSION}-rdkafka php${PHP_VERSION}-bz2 php${PHP_VERSION}-xdebug \
        php${PHP_VERSION}-yaml \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/log/php/ && chmod -R 0777 /var/log/php/ \
    && mkdir -p /usr/etc/php-fpm.d/ \
    && update-ca-certificates -v \
    && rm -f /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && mv /tmp/php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && mv /tmp/00-env.ini /etc/php/${PHP_VERSION}/fpm/conf.d/00-env.ini \
    && cp /etc/php/${PHP_VERSION}/fpm/conf.d/00-env.ini /etc/php/${PHP_VERSION}/cli/conf.d/00-env.ini \
    && mv /tmp/root_ca.crt /usr/local/share/ca-certificates/root_ca.crt \
    && mv /tmp/logrotate-php-fpm /etc/logrotate.d/php-fpm \
    && rm -f /tmp/php-fpm.conf /tmp/00-env.ini /tmp/root_ca.crt /tmp/logrotate-php-fpm

CMD ["/bin/bash", "-c", "cron;/run_on_start.sh;php-fpm${PHP_VERSION} -F"]

EXPOSE 9000
