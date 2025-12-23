FROM debian:stretch

ENV PHP_VERSION=7.2.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apache2 \
    apache2-dev \
    wget \
    ca-certificates \
    build-essential \
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
    --with-openssl \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --enable-zip \
    && make -j$(nproc) \
    && make install

RUN cp php.ini-development /usr/local/lib/php.ini

RUN a2enmod rewrite vhost_alias

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
