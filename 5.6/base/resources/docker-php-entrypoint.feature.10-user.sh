#!/bin/bash
set -e

if [ -z "$RUN_SILENT" ]; then
    echo "Process feature file: docker-php-entrypoint.feature.10-user.sh"
fi

if [ -z "$RUN_AS_ROOT" ]; then

    # Ensure group
    if ! getent group $APP_GROUP_ID >/dev/null 2>/dev/null; then
        groupadd -g $APP_GROUP_ID $APP_GROUP_NAME
    fi

    # Ensure user
    if ! id $APP_USER_ID >/dev/null 2>/dev/null; then
        useradd -u $APP_USER_ID -g $APP_GROUP_ID -m -s /bin/bash $APP_USER_NAME
    fi

    # Add user to sudoers
    echo $APP_USER_NAME ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/$APP_USER_NAME
    chmod 0440 /etc/sudoers.d/$APP_USER_NAME

    # Output service user
    if [ -z "$RUN_SILENT" ]; then
        echo "Run as user: $APP_USER_NAME[id:$APP_USER_ID]:$APP_GROUP_NAME[id:$APP_GROUP_ID]"
    fi
else
    # Output service user: root
    if [ -z "$RUN_SILENT" ]; then
        echo "Run as root"
    fi
fi
