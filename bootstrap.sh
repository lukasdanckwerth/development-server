#!/bin/bash
set -u
set -e

log() {
  echo && echo -e "[bootstrap]  ${*}" && echo
}

# === -------------------------------------------------------------- ===
log "Update"
apt-get update
apt-get upgrade --assume-yes

# === -------------------------------------------------------------- ===
log "Install dependencies"
apt-get install --assume-yes \
    git \
    zip \
    unzip \
    php \
    php-cli \
    php-zip \
    curl \
    wget \
    vim \
    docker.io \
    docker-compose

apt-get remove apache2 --assume-yes

# === -------------------------------------------------------------- ===
log "Add user vagrant to group docker"
usermod -aG docker vagrant

# === -------------------------------------------------------------- ===
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

# === -------------------------------------------------------------- ===
log "Install apache"

# pushd /home/vagrant/apache
# docker-compose up -d
# popd

# pushd /home/vagrant/traefik
# docker network create web
# docker-compose up -d
# popd

# === -------------------------------------------------------------- ===
log "Customize .profile"
echo "" >> /home/vagrant/.profile
echo "cd /srv/Developer" >> /home/vagrant/.profile

log "Reboot"
reboot
