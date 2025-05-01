#!/bin/bash
set -e

# Prepare defaults
APP_USER_NAME="developer"
APP_USER_ID="1000"
APP_GROUP_NAME="developer"
APP_GROUP_ID="1000"

# Setup application user & group
if [ -n "$USER_NAME" ]; then
	APP_USER_NAME=$USER_NAME
	unset USER_NAME
fi

if [ -n "$USER_ID" ]; then
	APP_USER_ID=$USER_ID
	unset USER_ID
fi

if [ -n "$GROUP_NAME" ]; then
	APP_GROUP_NAME=$GROUP_NAME
	unset GROUP_NAME
fi

if [ -n "$GROUP_ID" ]; then
	APP_GROUP_ID=$GROUP_ID
	unset GROUP_ID
fi

if ! getent group $APP_GROUP_ID >/dev/null 2>/dev/null; then
	echo "Group not found! Create group: $APP_GROUP_NAME[id:$APP_GROUP_ID]"
	groupadd -g $APP_GROUP_ID $APP_GROUP_NAME
fi

if ! id $APP_USER_ID >/dev/null 2>/dev/null; then
	echo "User not found! Create user: $APP_USER_NAME[id:$APP_USER_ID]"
	useradd -u $APP_USER_ID -g $APP_GROUP_ID -m -s /bin/bash $APP_USER_NAME
fi

# Add user to sudoers
echo $APP_USER_NAME ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/$APP_USER_NAME
chmod 0440 /etc/sudoers.d/$APP_USER_NAME

# Set apache user & group
sudo sed -i "s|\${APACHE_RUN_USER\:=www-data}|\${APACHE_RUN_USER\:=$APP_USER_NAME}|g" /etc/apache2/envvars
sudo sed -i "s|\${APACHE_RUN_GROUP\:=www-data}|\${APACHE_RUN_GROUP\:=$APP_GROUP_NAME}|g" /etc/apache2/envvars

# Set port to non-priviliged (8800, 8443)
sudo sed -i "s|\:80>|\:8800>|g" /etc/apache2/sites-available/default*.conf
sudo sed -i "s|\:443>|\:8443>|g" /etc/apache2/sites-available/default*.conf
sudo sed -i "s|Listen 80|Listen 8800|g" /etc/apache2/ports.conf
sudo sed -i "s|Listen 443|Listen 8443|g" /etc/apache2/ports.conf

# Process environment variables
sudo sed -i "s|\$WEB_SERVER_NAME|${WEB_SERVER_NAME:=localhost}|g" /etc/apache2/sites-available/default*.conf
sudo sed -i "s|\$WEB_SERVER_ALIAS|${WEB_SERVER_ALIAS:=web}|g" /etc/apache2/sites-available/default*.conf
sudo sed -i "s|\$WEB_SERVER_ADMIN|${WEB_SERVER_ADMIN:=webmaster@localhost}|g" /etc/apache2/sites-available/default*.conf
sudo sed -i "s|\$WEB_DOCUMENT_ROOT|${WEB_DOCUMENT_ROOT:=/var/www/html}|g" /etc/apache2/sites-available/default*.conf

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
	sudo -u \#$APP_USER_ID -g \#$APP_GROUP_ID mkdir -p "${WEB_DOCUMENT_ROOT:=/var/www/html}"
fi

# setup xdebug configuration by environment variable
if [ -n "${XDEBUG_CLIENT_HOST}" ]; then
  /bin/bash /usr/local/bin/docker-php-entrypoint.extend.xdebug.sh;
fi

# Process external entryscript (if present)
if [ -f /usr/local/bin/docker-php-entrypoint.external.sh ]; then
	echo "# Processing /usr/local/bin/docker-php-entrypoint.external.sh ..."
	chown -h $APP_USER_NAME:$APP_GROUP_NAME /usr/local/bin/docker-php-entrypoint.external.sh
	chmod +x /usr/local/bin/docker-php-entrypoint.external.sh
	/bin/bash /usr/local/bin/docker-php-entrypoint.external.sh
fi

# ORIGINAL:
##################################################################################################################
# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
