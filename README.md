# development-server

- [development-server](#development-server)
  - [Getting started](#getting-started)
  - [VM Info](#vm-info)
  - [Provisioning](#provisioning)
  - [VM lifecycle](#vm-lifecycle)
  - [Overview](#overview)

## Getting started

**1.** Clone repository und change directory.

```
git clone --recurse-submodules git@github.com:lukasdanckwerth/development-server.git \
&& cd development-server
```

**2.** Start virtual machine.

```bash
vagrant up
```

**3.** Update `/hosts` file. Add following lines to the end of the `/etc/hosts` file.

```hosts
192.168.56.2 development-server development-server.local
192.168.56.2 workspace.development-server workspace.development-server.local
192.168.56.2 webapps.development-server webapps.development-server.local
```

Alternatively you can use the [`makefile`](makefile) command run as root.

```bash
sudo make update-hosts-file
```

**4.** Install [Launch Agent](launch-agend.plist) to `~/Library/LaunchAgents` with [`makefile`](makefile) command.

```bash
make install-launch-agent
```

To remove the [Launch Agent](launch-agend.plist) at any time you can use the follwing command.

```bash
make remove-launch-agent
```

**5.** Install terminal command `development-server` to ssh into virtual machine.

```bash
sudo make install-ssh-command
```

## VM Info

Following informations are used in the [`Vagrantfile`](Vagrantfile).
|Info|Value|
|----|-----|
| Box | `ubuntu/focal64` |
| Name | `development-server` |
| RAM | `2048` |
| CPUs | `1` |
| IP | `192.168.56.2` |

Following directories will be synchronized from host to guest.
|Host|Guest|
|----|-----|
| `~/Developer` | `/srv/Developer` |

## Provisioning

Following directory will be created inside the VM:

```bash
/home/vagrant/developer
```

## VM lifecycle

```bash
# Start machine
vagrant up

# Stop machine
vagrant halt

# Recreate (--force to avoid prompt)
vagrant destroy --force && vagrant up

# Rerun provisioning
vagrant provision
```

## Overview
