WORK_DIR=$(shell pwd)
USER=$(shell whoami)
LAUNCH_AGEND_NAME=development-server.autostart.plist
LAUNCH_AGEND_FILE=${HOME}/Library/LaunchAgents/${LAUNCH_AGEND_NAME}

install:
	@echo "COMMANDS:"
	@echo ""
	@echo "update-hosts-file               Updates the /etc/hosts file (run as root)"
	@echo "install-launch-agent            Installs the launch agent plist file"
	@echo "remove-launch-agent             Removes the launch agent plist file"
	@echo ""

update-hosts-file:
ifneq ($(shell id -u), 0)
	@echo "You must be root to perform this action."
	@exit 1
endif
	@echo "Update hosts file"
	echo "192.168.56.2 development-server development-server.local" >> /etc/hosts
	echo "192.168.56.2 workspace.development-server workspace.development-server.local" >> /etc/hosts
	echo "192.168.56.2 webapps.development-server webapps.development-server.local" >> /etc/hosts

install-launch-agent:
ifneq ("$(wildcard $(LAUNCH_AGEND_FILE))","")
	@echo "Launch agent already existing at ${LAUNCH_AGEND_FILE}"
else
	@sed 's~__WORKING_DIRECTORY__~${WORK_DIR}~g' launch-agend.plist > ${LAUNCH_AGEND_NAME}
	@ln -s ${WORK_DIR}/${LAUNCH_AGEND_NAME} ${LAUNCH_AGEND_FILE}
endif

remove-launch-agent:
ifeq ("$(wildcard $(LAUNCH_AGEND_FILE))","")
	@echo "Launch agent already NOT existing at ${LAUNCH_AGEND_FILE}"
else
	@rm -rf ${LAUNCH_AGEND_FILE}
endif
