# Distro: Debian 9.x Stretch (https://hub.docker.com/_/php)
FROM hhdev/php:7.0-apache

LABEL maintainer="Heiko Hardt <heiko@hardt.dev>" \
    description="Yet another Apache Mod-PHP environment focused on TYPO3 and Symfony applications (development)"

# Set non-interactive mode for apt-get
ARG DEBIAN_FRONTEND=noninteractive
# Set terminal type
ARG TERM=xterm    
# https://getcomposer.org/download/ (Latest LTS)
ARG COMPOSER1_VERSION="1.10.27"
ARG COMPOSER2_VERSION="2.2.25"
# https://xdebug.org/
ARG PHP_XDEBUG_VERSION="2.7.2"

# Extend ENTRYPOINT
COPY resources /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-entrypoint.feature.*

# Development tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        default-mysql-client \
        git \
        mc \
        openssh-client \
        sqlite3 \
        unzip  \
        vim \
        wget \
        zsh \
    && rm -rf /var/lib/apt/lists/* \
    # Update PHP setup
    && pecl install xdebug-${PHP_XDEBUG_VERSION} \
    # && docker-php-ext-enable xdebug ... will be enabled by environment variable
    # Copy php ini (php.ini-development|php.ini-production)
    && cp "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini" \
    # Add custom ini parameter
    && printf "[PHP]\nmemory_limit = 512M\nmax_execution_time = 3600\nmax_input_vars = 1500\nupload_max_filesize = 50M\npost_max_size = 50M\n\n[Date]\ndate.timezone = Europe/Berlin\n" > "$PHP_INI_DIR/conf.d/additional.ini" \
    # Fetch & install composer binary
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --version=${COMPOSER1_VERSION} --filename=composer-1x.phar \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --version=${COMPOSER2_VERSION} --filename=composer-2x.phar \
    && ln -s /usr/local/bin/composer-2x.phar /usr/local/bin/composer
