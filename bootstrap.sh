#!/bin/bash
set -u
set -e

log() {
  echo && echo -e "[bootstrap]  ${*}" && echo
}

log "Update"
apt-get update && apt-get upgrade --assume-yes

log "Install dependencies"
apt-get install --assume-yes \
    git \
    zip unzip \
    php \
    php-cli \
    php-zip \
    curl \
    wget \
    vim \
    apache2 \
    docker.io docker-compose

log "Install composer"
pushd /tmp/
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
popd
if [[ -f "/usr/local/bin/composer" ]]; then
    log "Successfully installed composer"
else
    exit 1
fi

log "Configure apache"
echo "$(hostname)" > "/etc/apache2/conf-available/servername.conf"
a2enmod rewrite
systemctl restart apache2

echo "
<!DOCTYPE html>
<html lang=\"en\">
  <head>
    <meta charset=\"utf-8\" />
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
    <link
      href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css\"
      rel=\"stylesheet\"
      integrity=\"sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3\"
      crossorigin=\"anonymous\"
    />
    <title>development-server</title>
  </head>
  <body>
    <div class=\"container\">
      <div class=\"row mt-4\">
        <div class=\"col-md-6 offset-md-3\">
            <h1>development-server</h1>
            <a href=\"http://192.168.56.2\">
                http://192.168.56.2
            </a>
            <a href=\"http://workspace.development-server\">
                http://workspace.development-server
            </a>
            <a href=\"http://webapps.development-server\">
                http://webapps.development-server
            </a>
        </div>
      </div>
    </div>
  </body>
</html>
" > /var/www/html/index.html

echo "
<VirtualHost *:80>
	ServerName development-server
	DocumentRoot /var/www/html
	<Directory /var/www/html>
		Options Indexes FollowSymLinks Includes ExecCGI
		AllowOverride All
		Order Allow,Deny
		Allow from all
		Require all granted
	</Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:80>
	ServerName workspace.development-server
	DocumentRoot /srv/Developer
	<Directory /srv/Developer>
        Options Indexes FollowSymLinks Includes ExecCGI
        AllowOverride All
        Order Allow,Deny
        Allow from all
        Require all granted
    </Directory>
	ErrorLog \${APACHE_LOG_DIR}/workspace.error.log
	CustomLog \${APACHE_LOG_DIR}/workspace.access.log combined
</VirtualHost>

<VirtualHost *:80>
    ServerName webapps.development-server
	ServerAlias webapps.development-server.local
    DocumentRoot /srv/Developer/WebApps	
	<Directory /srv/Developer>
        Options Indexes FollowSymLinks Includes ExecCGI
        AllowOverride All
        Order Allow,Deny
        Allow from all
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/webapps.error.log
    CustomLog \${APACHE_LOG_DIR}/webapps.access.log combined
</VirtualHost>

" > /etc/apache2/sites-available/000-development-server.local.conf

a2ensite 000-development-server.local.conf

reboot