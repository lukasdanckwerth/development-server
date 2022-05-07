# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_BASE = "ubuntu/focal64"
BOX_NAME = "development-server"
BOX_RAM_MB = "2048"
BOX_CPU_COUNT = "2"
BOX_IP = "192.168.56.2"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  # Define base box.
  config.vm.box = BOX_BASE
  config.vm.hostname = BOX_NAME
  
  # Disable default `/vagrant` directory synchronization.
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder "~/Developer", "/srv/Developer", create: true

  config.vm.provider "virtualbox" do |v|
    v.name = BOX_NAME
    v.cpus = BOX_CPU_COUNT
    v.memory = BOX_RAM_MB
  end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.56.2"

  # Run shell script for provisioning.
  config.vm.provision :shell, path: "bootstrap.sh"
end
