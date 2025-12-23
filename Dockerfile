FROM debian:stretch

ENV PHP_VERSION=7.2.0
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y \
    apache2 \
    apache2-dev \
    wget \
    ca-certificates \
    build-essential \
    pkg-config \
    libxml2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    libssl-dev \
    zlib1g-dev \
    git \
    nano \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

RUN wget https://museum.php.net/php7/php-${PHP_VERSION}.tar.gz \
    && tar -xzf php-${PHP_VERSION}.tar.gz

WORKDIR /usr/src/php-${PHP_VERSION}

RUN ./configure \
    --with-apxs2=/usr/bin/apxs \
    --with-mysqli \
    --with-pdo-mysql \
    --enable-mbstring \
    --with-curl \
    --with-zlib \
    --with-openssl=/usr \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-freetype-dir=/usr \
    --enable-zip \
    --with-libdir=lib/x86_64-linux-gnu \
    && make -j$(nproc) \
    && make install

RUN cp php.ini-development /usr/local/lib/php.ini

RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite vhost_alias && a2enmod php7

# RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]