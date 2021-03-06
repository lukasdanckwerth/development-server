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

log "Add user vagrant to group docker"
usermod -aG docker vagrant

log "Install composer"
pushd /tmp/
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
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
<VirtualHost *:81>
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

<VirtualHost *:81>
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

<VirtualHost *:81>
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

echo "
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen 81

<IfModule ssl_module>
	Listen 443
</IfModule>

<IfModule mod_gnutls.c>
	Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
" > /etc/apache2/ports.conf

echo "
<VirtualHost *:81>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with \"a2disconf\".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
" > /etc/apache2/sites-enabled/000-default.conf

a2ensite 000-development-server.local.conf

log "Customize .profile"
echo "" >> /home/vagrant/.profile
echo "cd /srv/Developer" >> /home/vagrant/.profile

log "Reboot"
reboot