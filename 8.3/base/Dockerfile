# Distro: Debian 11.x Bullseye (https://hub.docker.com/_/php)
FROM php:8.3.20-apache-bullseye

# Distro: Debian 12.x bookworm (https://hub.docker.com/_/php)
# FROM php:8.1.32-apache-bookworm
# Rollback to Bullseye cause issue: https://github.com/dunglas/symfony-docker/issues/614
# problem: libcurl versions 7.87.0, 7.88.0 and 7.88.1 in bookworm

LABEL maintainer="Heiko Hardt <heiko@hardt.dev>" \
    description="Yet another Apache Mod-PHP environment focused on TYPO3 and Symfony applications"

# Set non-interactive mode for apt-get
ARG DEBIAN_FRONTEND=noninteractive
# Set terminal type
ARG TERM=xterm
# https://pecl.php.net/package/apcu
ARG PHP_APCU_VERSION="5.1.24"

# Locals & Timezone
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales locales-all tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Europe/Berlin" > /etc/timezone \
    && rm -f /etc/localtime \
    && ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# Set root user and add sudo support.
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && rm -rf /var/lib/apt/lists/* \
    # Configuration sudoers
    && echo "Defaults env_keep=\"http_proxy https_proxy no_proxy\"" > /etc/sudoers.d/defaults \
    && chmod 0440 /etc/sudoers.d/defaults \
    # Set root password: pass
    && echo "root:pass" | chpasswd

# Prepare SSL
RUN mkdir /etc/ssl/localhost/ \
    # Create a Private Key
    && openssl genrsa -out /etc/ssl/localhost/server.key 2048 \
    # Generate a Certificate Signing Request (CSR)
    && openssl req -new -key /etc/ssl/localhost/server.key -out /etc/ssl/localhost/server.csr -subj "/C=DE/ST=NRW/L=Cologne/O=Private Inc/OU=Development/CN=localhost" \
    # Generate a Self-Signed Certificate
    && openssl x509 -req -days 3650 -in /etc/ssl/localhost/server.csr -signkey /etc/ssl/localhost/server.key -out /etc/ssl/localhost/server.crt \
    # Grant global read permission
    && chmod 644 /etc/ssl/localhost/server.key \
    # Prepare ca-certificates
    && mkdir /usr/share/ca-certificates/localhost/ \
    && cp /etc/ssl/localhost/server.crt /usr/share/ca-certificates/localhost/server.crt \
    && echo "localhost/server.crt" >> /etc/ca-certificates.conf \
    && update-ca-certificates

# Setup Apache
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername \
    # Enable module(s)
    && a2enmod rewrite \
    && a2enmod ssl \
    # Apache vhosts file(s)
    ###############################################################################################
    && a2dissite 000-default \
    && mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/default.conf \
    && sed -ri -e 's|/var/www/html|$WEB_DOCUMENT_ROOT|g' /etc/apache2/sites-available/default*.conf \
    && sed -ri -e 's|ServerAdmin webmaster@localhost|ServerAdmin $WEB_SERVER_ADMIN\n\n\tServerName $WEB_SERVER_NAME\n\tServerAlias $WEB_SERVER_ALIAS|g' /etc/apache2/sites-available/default*.conf \
    && sed -ri -e 's|#Include conf-available/serve-cgi-bin.conf|#Include conf-available/serve-cgi-bin.conf\n\n        # Environment variables:\n        # SetEnv KEY VALUE|g' /etc/apache2/sites-available/default*.conf \
    # Prepare ssl certificates
    && sed -ri -e 's|/etc/ssl/certs/ssl-cert-snakeoil.pem|/etc/ssl/localhost/server.crt|g' /etc/apache2/sites-available/default-ssl.conf \
    && sed -ri -e 's|/etc/ssl/private/ssl-cert-snakeoil.key|/etc/ssl/localhost/server.key|g' /etc/apache2/sites-available/default-ssl.conf \
    # enable sites
    && a2ensite default \
    && a2ensite default-ssl

# PHP: extensions & configuration
###################################################################################################
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ghostscript \
        graphicsmagick \
        libc-client-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libkrb5-dev \
        libldap2-dev \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libxpm-dev \
        libzip-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install apcu-${PHP_APCU_VERSION} \
    && docker-php-ext-install -j$(nproc) bcmath \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-configure gd --with-jpeg --with-xpm --with-webp --with-freetype \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j$(nproc) imap \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) ldap \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) opcache \
    && docker-php-ext-install -j$(nproc) pcntl \
    && docker-php-ext-install -j$(nproc) pdo \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) soap \
    && docker-php-ext-install -j$(nproc) sockets \
    && docker-php-ext-install -j$(nproc) xml \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-enable apcu

# Extend ENTRYPOINT
COPY resources /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-php-entrypoint.extend.* \
    && chmod +x /usr/local/bin/docker-php-entrypoint.feature.* \
    && mv /usr/local/bin/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint.original \
    && mv /usr/local/bin/docker-php-entrypoint.extend.sh /usr/local/bin/docker-php-entrypoint

# Production environment
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    # Add default ini parameter
    && printf "[PHP]\nmemory_limit = 256M\nmax_execution_time = 240\nmax_input_vars = 1500\nupload_max_filesize = 50M\npost_max_size = 50M\n\n[Date]\ndate.timezone = Europe/Berlin\n" > "$PHP_INI_DIR/conf.d/additional.ini"

EXPOSE 8800
EXPOSE 8443

WORKDIR /var/www/html
