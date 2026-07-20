#!/bin/bash
# NOTE: this script is done in one giant if-else so that it can be run with "source".
#       You can't use "exit" with the "source" command or the whole terminal will exit.

# CONFIGURE THE SCRIPT HERE
ssh_user_name="root"
mconn_ip_mask="10.20.10"

# We should have one argument for "help", or two otherwise. Never zero.
if [[ $# -eq 0 ]]; then
  echo "Invalid number of arguments."

# Display the help text if requested.
elif [[ $1 == "help" ]]; then
  echo -e "Usage: bsh <ip-address>
  
Project options:
 Bambauer MConn

For the IP address, specify the last two digits.\nThe first 3 segments are the same for each device."

# If we weren't displaying the help text we should have exactly 2 arguments.
elif [[ $# -ne 1 ]]; then
  echo "Invalid number of arguments."

# SSH into the correct device.
else
  ip_prefix="${mconn_ip_mask}"
  
  # MConns always have the password "mrsroot". https://mconn.dev/1_Getting_Started/Setting_up_MConn.html
  sshpass -p "mrsroot" ssh -o StrictHostKeyChecking=no ${ssh_user_name}@${ip_prefix}.$1
fi
