# Distro: Debian 9.x Stretch (https://hub.docker.com/_/php)
FROM hhdev/php:7.0-apache

LABEL maintainer="Heiko Hardt <heiko@hardt.dev>" \
    description="Yet another Apache Mod-PHP environment focused on TYPO3 and Symfony applications (vscode)"

# Set non-interactive mode for apt-get
ARG DEBIAN_FRONTEND=noninteractive
# Set terminal type
ARG TERM=xterm
    
# Switch sources and upgrade environment (https://debiansupport.com/mirrors)
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    # Temporary switch to buster
    && mv /etc/apt/sources.list /etc/apt/sources.list.temporary \
    && echo "deb http://deb.debian.org/debian/ buster main non-free contrib" > /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb http://security.debian.org/ buster/updates main non-free contrib" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --only-upgrade \
        libstdc++6 \
        libc6-dev -y \
    && rm -rf /var/lib/apt/lists/* \
    # Restore sources
    && mv /etc/apt/sources.list.temporary /etc/apt/sources.list
