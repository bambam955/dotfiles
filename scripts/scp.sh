#!/bin/bash

# CONFIGURE THE SCRIPT HERE
ssh_user_name="root"
mconn_ip_mask="10.20.10"
vm_bambauer_buildroot_debug_exe="/home/bennett-moore/projects/bambauer/build/display-app-buildroot-debug/BambauerPump"
vm_bambauer_yocto_debug_exe="/home/bennett-moore/projects/bambauer/build/display-app-yocto-debug/normal.app.bam"
vm_bambauer_old_buildroot_exe="/home/bennett-moore/projects/bambauer/build/display-app-old-buildroot-debug/BambauerPump"
vm_power_pack_buildroot_exe="/home/bennett-moore/projects/bambauer/build/power-pack-display-buildroot-debug/PowerPackDisplay"
vm_power_pack_yocto_exe="/home/bennett-moore/projects/bambauer/build/power-pack-display-yocto-debug/normal.app.powerpack"
remote_bambauer_buildroot_exe="/opt/BambauerPump/bin/BambauerPump"
remote_bambauer_yocto_exe="/opt/bin/normal.app.bam"
remote_power_pack_buildroot_exe="/opt/PowerPackDisplay/bin/PowerPackDisplay"
remote_power_pack_yocto_exe="/opt/bin/normal.app.powerpack"

# We should always have at least one argument. Never zero.
if [[ $# -eq 0 ]]; then
  echo "Invalid number of arguments."
  exit 1
fi

# Display the help text if requested.
if [[ $1 == "help" ]]; then
  echo -e "Usage: sscp <project> <ip-address> <os-type>(optional)
  
Project options:
b\tBambauer display-app\nbo\tBambauer display-app-old\nbpp\tBambauer power-pack-display

For the IP address, specify the last two digits.\nThe first 3 segments are the same for each device.

For Bambauer display-app or power-pack-display, the third argument must be the OS type:
b\tBuildroot\ny\tYocto

To use the release mode for either of those projects, specify 'r' as the fourth argument."
  exit 0
fi

# If we weren't displaying the help text we should have at least 2 arguments.
if [[ $# -lt 2 ]]; then
  echo "Invalid number of arguments."
  exit 1
fi

# These are the variables that need set for each possible combination of options.
ip_prefix=""
vm_file=""
remote_file=""

# Set the files and IP address correctly in the switch.
case "$1" in
  # We should have three arguments for bambauer, with the third being for the OS.
  "b")
    if [[ $# -gt 4 ]]; then
      echo "Invalid number of arguments."
      exit 1
    fi

    ip_prefix=${mconn_ip_mask}
    
    case "$3" in
      "b")
      	if [[ $4 == "r" ]]; then
      	  vm_file=${vm_bambauer_buildroot_release_exe}
      	else
          vm_file=${vm_bambauer_buildroot_debug_exe}
        fi
        remote_file=${remote_bambauer_buildroot_exe}
        ;;
      "y")
        if [[ $4 == "r" ]]; then
          vm_file=${vm_bambauer_yocto_release_exe}
        else
          vm_file=${vm_bambauer_yocto_debug_exe}
        fi
        remote_file=${remote_bambauer_yocto_exe}
        ;;
      *)
        echo "Valid OS options are 'b' and 'y'."
        exit 1
        ;;
    esac
    ;;
  "bo")
    ip_prefix=${mconn_ip_mask}
    vm_file=${vm_bambauer_old_buildroot_exe}
    remote_file=${remote_bambauer_buildroot_exe}
    ;;
  "bpp")
    if [[ $# -ne 3 ]]; then
      echo "Invalid number of arguments."
      exit 1
    fi
  
    ip_prefix=${mconn_ip_mask}
    
    case "$3" in
      "b")
        vm_file=${vm_power_pack_buildroot_exe}
        remote_file=${remote_power_pack_buildroot_exe}
        ;;
      "y")
        vm_file=${vm_power_pack_yocto_exe}
        remote_file=${remote_power_pack_yocto_exe}
        ;;
      *)
        echo "Valid OS options are 'b' and 'y'."
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Valid project options are 'b', 'bo', and 'bpp'."
    exit 1
    ;;
esac

user_address=${ssh_user_name}@${ip_prefix}.$2

echo "Copying ${vm_file} to ${user_address}:${remote_file}..."
scp ${vm_file} ${user_address}:${remote_file}
  
