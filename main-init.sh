#!/bin/bash

wdir=$(dirname "$0")
os_type="UNKNOWN"

# Detect OS via /etc/os-release (if available)
if [[ -f /etc/os-release ]]; then
  os_info=$(grep "VERSION_ID" /etc/os-release 2>/dev/null)
  os_name=$(grep "PRETTY_NAME" /etc/os-release 2>/dev/null)
  echo " OS : ${os_name}" 
  if [[ $(echo "$os_info" | grep -c "ubuntu") -gt 0 || $(echo "$os_info" | grep -c "debian") -gt 0 ]]; then
     os_type="UBUNTU"
  elif [[ $(echo "$os_info" | grep -c "rhel") -gt 0 || $(echo "$os_info" | grep -c "centos") -gt 0 || $(echo "$os_info" | grep -c "fedora") -gt 0 ]]; then
     os_type="RHEL"
  fi
fi

# Define timestamps
start_t=$(date +%H:%M:%S)
echo "Starting server init at $start_t"

# Add OS-specific logic or initialization...
$wdir/01-packages.sh

date_output=$(date +%H:%M:%S)
echo "End of server init at $date_output ..."
