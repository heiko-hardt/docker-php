#!/bin/bash
set -e

if [ -z "$RUN_SILENT" ]; then
    echo "Process feature file: docker-php-entrypoint.feature.composer.sh"
fi

if [ -n "$ENABLE_COMPOSER_VERSION_1" ]; then

    if [ -z "$RUN_SILENT" ]; then
        echo "  Enable composer verion 1.x as default"
    fi

    rm -f /usr/local/bin/composer
    ln -s /usr/local/bin/composer-1x.phar /usr/local/bin/composer

fi
