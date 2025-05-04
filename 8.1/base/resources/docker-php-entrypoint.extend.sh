#!/bin/bash
set -e

# Set defaults
export APP_USER_NAME=${USER_NAME:-'developer'} \
	APP_USER_ID=${USER_ID:-'1000'} \
	APP_GROUP_NAME=${GROUP_NAME:-'developer'} \
	APP_GROUP_ID=${GROUP_ID:-'1000'}

# Process feature scripts
for file in /usr/local/bin/docker-php-entrypoint.feature.*.sh; do
	/bin/bash $file
done

# Unset defaults
unset APP_USER_NAME APP_USER_ID APP_GROUP_NAME APP_GROUP_ID

# ORIGINAL:
##################################################################################################################
# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
