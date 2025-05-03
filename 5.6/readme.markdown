# Environment variables

User configuration:
| name | description | default |
| :--- | :--- |:--- |
| `USER_NAME` | Overwrite the **user name** which is used | developer |
| `USER_ID` |  Overwrite the **user id** which is used | 1000 |
| `GROUP_NAME` |  Overwrite the **group name** which is used | developer |
| `GROUP_ID` | Overwrite the **group id** which is used | 1000 |
| `RUN_AS_ROOT` | If this variable is set, the process will be executed as **root** | - |

Webserver configuration:
| name | description | default | example(s) |
| :--- | :--- |:--- |:--- |
| `WEB_SERVER_NAME` | Hostname and port that the server uses to identify itself [(apache documentation)](https://httpd.apache.org/docs/2.4/en/mod/core.html#servername). | localhost | 'www-application-de.company.dev' |
| `WEB_SERVER_ALIAS` | Alternate names for a host used when matching requests to name-virtual hosts [(apache documentation)](https://httpd.apache.org/docs/2.4/en/mod/core.html#serveralias). | web | 'web web-symfony-de' |
| `WEB_SERVER_ADMIN` | Email address that the server includes in error messages sent to the client [(apache documentation)](https://httpd.apache.org/docs/2.4/en/mod/core.html#serveradmin). | webmaster@localhost | 'webmaster@company.dev' |
| `WEB_DOCUMENT_ROOT` | Directory that forms the main document tree visible from the web [(apache documentation)](https://httpd.apache.org/docs/2.4/en/mod/core.html#documentroot). | /var/www/html | '/var/www/html/public' |
| `WEB_ENV_VARS` | Sets one (or more) environment variable(s) [(apache documentation)](https://httpd.apache.org/docs/2.4/en/mod/core.html#setenv). | - | 'EXAMPLE_FOO foo, EXAMPLE_BAR bar' |

Development configuration:
| name | description | example(s) |
| :--- | :--- |:--- |
| `XDEBUG_CLIENT_HOST` | client hostname (or ip address) for xdebug2 configuration. If set xdebug will be configured and enabled |'host.docker.internal' |
| `ENABLE_COMPOSER_VERSION_1` | If set, composer 1.x will be configured as default. Default is composer 2.x | - | 

Common configuration:
| name | description |
| :--- | :--- |
| `RUN_SILENT` | All configuration outputs are suppressed  |
