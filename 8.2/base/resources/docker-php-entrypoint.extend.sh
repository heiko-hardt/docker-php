#!/bin/bash
set -e

# Ensure user and group
USER_NAME="developer"; USER_ID="$(id -u)"; GROUP_NAME="developer"; GROUP_ID="$(id -g)";
if ! getent group $GROUP_ID >/dev/null 2>/dev/null ; then
  echo "group[id:$GROUP_ID] not found! creating group ...";
  echo "pass" | su -c "groupadd -g $GROUP_ID $GROUP_NAME" >/dev/null 2>/dev/null
fi
if ! id $USER_ID >/dev/null 2>/dev/null ; then
  echo "user[id:$USER_ID] not found! creating user ...";
  echo "pass" | su -c "useradd -u $USER_ID -g $GROUP_ID -m -s /bin/bash $USER_NAME" >/dev/null 2>/dev/null
fi
USER_NAME="$(id -un)"; GROUP_NAME="$(id -gn)";

# Add user to sudoers
echo "pass" | su -c "echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME" >/dev/null 2>/dev/null
echo "pass" | su -c "chmod 0440 /etc/sudoers.d/$USER_NAME" >/dev/null 2>/dev/null

# Set apache user & group
sudo sed -i "s|\${APACHE_RUN_USER\:=www-data}|\${APACHE_RUN_USER\:=$USER_NAME}|g" /etc/apache2/envvars
sudo sed -i "s|\${APACHE_RUN_GROUP\:=www-data}|\${APACHE_RUN_GROUP\:=$GROUP_NAME}|g" /etc/apache2/envvars

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
  readarray -td, envVars <<< "$WEB_ENV_VARS";
  for envVar in "${envVars[@]}"; do
    SET_WEB_ENV+="        SetEnv $(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'<<< ${envVar})\n";
  done
fi
if [ -n "$SET_WEB_ENV" ]; then sudo sed -i "s|        # SetEnv KEY VALUE|$SET_WEB_ENV|g" /etc/apache2/sites-available/default*.conf; fi

# Ensure document root
if [ ! -d "${WEB_DOCUMENT_ROOT:=/var/www/html}" ]; then
  sudo -u \#$USER_ID -g \#$GROUP_ID mkdir -p "${WEB_DOCUMENT_ROOT:=/var/www/html}"
fi

# Process external entryscript (if present)
if [ -f /usr/local/bin/docker-php-entrypoint.external.sh ]; then
  echo "# Processing /usr/local/bin/docker-php-entrypoint.external.sh ...";
  sudo chown -h $USER_NAME:$GROUP_NAME /usr/local/bin/docker-php-entrypoint.external.sh
  sudo chmod +x /usr/local/bin/docker-php-entrypoint.external.sh
  /bin/bash /usr/local/bin/docker-php-entrypoint.external.sh
fi

# ORIGINAL:
##################################################################################################################
# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
