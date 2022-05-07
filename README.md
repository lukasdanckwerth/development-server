# development-server

- [Getting started](#getting-started)
- [VM Info](#vm-info)
- [VM lifecycle](#vm-lifecycle)

## Getting started

**1.** Clone repository und change directory.
```
git clone git@github.com:lukasdanckwerth/development-server.git \
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
Alternatively you can use the `makefile` command.
```bash
make update-hosts-file
```

**4.** Install [Launch Agent](launch-agend.plist) to `~/Library/LaunchAgents` with `makefile` command.
```bash
make install-launch-agent
```
To remove the [Launch Agent](launch-agend.plist)  in the future use.
```bash
make remove-launch-agent
```

## VM Info
Following informations are used in the [`Vagrantfile`](Vagrantfile).
|Info|Value|
|----|-----|
| Box | `ubuntu/focal64` |
| Name | `development-server` |
| RAM | `2048` |
| CPUs | `2` |
| IP | `192.168.56.2` |

Following directories will be synchronized from host to guest.
|Host|Guest|
|----|-----|
| `~/Developer` | `/src/Developer` |

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