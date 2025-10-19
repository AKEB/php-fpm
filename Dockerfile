FROM akeb/docker-debian12:latest

ARG PHP_VERSION="8.3"
ENV PHP_VERSION=${PHP_VERSION}


RUN apt-get update -y --allow-insecure-repositories \
    && apt-get install -y --allow-unauthenticated \
    php${PHP_VERSION}-fpm php${PHP_VERSION}-common \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-igbinary \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-memcached \
    php${PHP_VERSION}-msgpack \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-mysqlnd \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-rdkafka \
    php${PHP_VERSION}-bz2 \
    php${PHP_VERSION}-xdebug \
    php${PHP_VERSION}-yaml \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/php/

RUN mkdir -p /usr/etc/php-fpm.d/
COPY php-fpm.conf /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
COPY 00-env.ini /etc/php/${PHP_VERSION}/fpm/conf.d/00-env.ini
COPY 00-env.ini /etc/php/${PHP_VERSION}/cli/conf.d/00-env.ini
COPY root_ca.crt /usr/local/share/ca-certificates/
COPY logrotate/php-fpm /etc/logrotate.d/
RUN update-ca-certificates -v

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

CMD ["/bin/bash", "-c", "cron;/run_on_start.sh;php-fpm${PHP_VERSION} -F"]

EXPOSE 9000
