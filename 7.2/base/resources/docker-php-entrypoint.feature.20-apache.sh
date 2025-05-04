#!/bin/bash
set -e

if [ -z "$RUN_SILENT" ]; then
	echo "Process feature file: docker-php-entrypoint.feature.20-apache.sh"
fi

if [ -z "$RUN_AS_ROOT" ]; then
	# Set apache user & group
	sed -i "s|\${APACHE_RUN_USER\:=www-data}|\${APACHE_RUN_USER\:=$APP_USER_NAME}|g" /etc/apache2/envvars
	sed -i "s|\${APACHE_RUN_GROUP\:=www-data}|\${APACHE_RUN_GROUP\:=$APP_GROUP_NAME}|g" /etc/apache2/envvars

	# Set port to non-priviliged (8800, 8443)
	sed -i "s|\:80>|\:8800>|g" /etc/apache2/sites-available/default*.conf
	sed -i "s|\:443>|\:8443>|g" /etc/apache2/sites-available/default*.conf
	sed -i "s|Listen 80|Listen 8800|g" /etc/apache2/ports.conf
	sed -i "s|Listen 443|Listen 8443|g" /etc/apache2/ports.conf
fi

# Process environment variables
sed -i "s|\$WEB_SERVER_NAME|${WEB_SERVER_NAME:=localhost}|g" /etc/apache2/sites-available/default*.conf
sed -i "s|\$WEB_SERVER_ALIAS|${WEB_SERVER_ALIAS:=web}|g" /etc/apache2/sites-available/default*.conf
sed -i "s|\$WEB_SERVER_ADMIN|${WEB_SERVER_ADMIN:=webmaster@localhost}|g" /etc/apache2/sites-available/default*.conf
sed -i "s|\$WEB_DOCUMENT_ROOT|${WEB_DOCUMENT_ROOT:=/var/www/html}|g" /etc/apache2/sites-available/default*.conf

# Process environment parameter
SET_WEB_ENV=''
if [ -n "$WEB_ENV_VARS" ]; then
	readarray -td, envVars <<<"$WEB_ENV_VARS"
	for envVar in "${envVars[@]}"; do
		SET_WEB_ENV+="        SetEnv $(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<<${envVar})\n"
	done
fi
if [ -n "$SET_WEB_ENV" ]; then sudo sed -i "s|        # SetEnv KEY VALUE|$SET_WEB_ENV|g" /etc/apache2/sites-available/default*.conf; fi

# Ensure document root
if [ ! -d "${WEB_DOCUMENT_ROOT:=/var/www/html}" ]; then
	if [ -z "$RUN_AS_ROOT" ]; then
		sudo -u \#$APP_USER_ID -g \#$APP_GROUP_ID mkdir -p "${WEB_DOCUMENT_ROOT:=/var/www/html}"
	else
		mkdir -p "${WEB_DOCUMENT_ROOT:=/var/www/html}"
	fi
fi
