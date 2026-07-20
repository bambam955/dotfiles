#!/bin/bash

if [[ "$( ip link show vcan0 )" =~ .*vcan0.*UNKNOWN.* && "$( ip link show vcan1 )" =~ .*vcan1.*UNKNOWN.* ]]; then
    echo "vcan interfaces already up and running."
    exit 0
fi

if [[ "$1" == "--use-askpass" ]]; then
    # Set up sudo to use the GNOME askpass tool, which looks really nice
    export SUDO_ASKPASS=/usr/lib/openssh/gnome-ssh-askpass

	# Set up vcan interfaces
	sudo -A modprobe vcan
	sudo -A ip link add dev vcan0 type vcan
	sudo -A ip link set up vcan0
	sudo -A ip link add dev vcan1 type vcan
	sudo -A ip link set up vcan1
	exit 0
else
	# Set up vcan interfaces
	sudo modprobe vcan
	sudo ip link add dev vcan0 type vcan
	sudo ip link set up vcan0
	sudo ip link add dev vcan1 type vcan
	sudo ip link set up vcan1
	exit 0
fi
