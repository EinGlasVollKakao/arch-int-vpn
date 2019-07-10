#!/bin/bash

# this script reads in the contents of a temporary file which contains the current
# iptables chain policies to check that they are in place before proceeding onto
# check tunnel connectivity. this file is generated by a line in the iptables.sh
# for the application container, and is removed at startup via the init.sh
# script. we use the temporary file to read in iptables chain policies, as we
# cannot perform any iptables instructions for non root users.

# function to verify iptables chain blocking policies are in place
check_iptables() {

	# check /tmp/checkiptables file exists
	if [ ! -f /tmp/checkiptables ]; then
		return 1
	fi

	# check all chain policies are set to drop
	cat /tmp/checkiptables | grep -q '\-P INPUT DROP' || return 1
	cat /tmp/checkiptables | grep -q '\-P FORWARD DROP' || return 1
	cat /tmp/checkiptables | grep -q '\-P OUTPUT DROP' || return 1

	return 0
}

if [[ "${DEBUG}" == "true" ]]; then
	echo "[debug] Waiting for iptables chain policies to be in place..."
fi

# loop and wait until iptables chain policies are in place
while ! check_iptables
do
	sleep 0.1
done

if [[ "${DEBUG}" == "true" ]]; then
	echo "[debug] iptables chain policies are in place"
fi