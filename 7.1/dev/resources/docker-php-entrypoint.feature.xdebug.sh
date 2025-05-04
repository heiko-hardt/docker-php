#!/bin/bash
set -e

if [ -z "$RUN_SILENT" ]; then
    echo "Process feature file: docker-php-entrypoint.feature.xdebug.sh"
fi

if [ -n "${XDEBUG_CLIENT_HOST}" ]; then

    if [ -z "$RUN_SILENT" ]; then
        echo "  Enable xdebug"
    fi

    FILE_XDEBUG='/usr/local/etc/php/conf.d/additional.xdebug.ini'
    PATH_XDEBUG='/usr/local/lib/php/extensions/no-debug-non-zts-20160303/xdebug.so'

    # Add configuration for xdebug
    cat <<EOT >>$FILE_XDEBUG
[Xdebug]
zend_extension=$PATH_XDEBUG

; https://2.xdebug.org/docs/all_settings#idekey
xdebug.idekey = PHPSTORM
; https://2.xdebug.org/docs/all_settings#default_enable
xdebug.default_enable = 0
; https://2.xdebug.org/docs/all_settings#remote_enable
xdebug.remote_enable = 1
; https://2.xdebug.org/docs/all_settings#remote_autostart
xdebug.remote_autostart = 0
; https://2.xdebug.org/docs/all_settings#remote_connect_back
xdebug.remote_connect_back = 0
; https://2.xdebug.org/docs/all_settings#profiler_enable
xdebug.profiler_enable = 0
; https://2.xdebug.org/docs/all_settings#remote_host
xdebug.remote_host = $XDEBUG_CLIENT_HOST
; https://2.xdebug.org/docs/all_settings#max_nesting_level
xdebug.max_nesting_level=450

EOT
fi
