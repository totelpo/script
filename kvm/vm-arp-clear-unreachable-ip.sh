#!/bin/bash
# set -e   # exit script when error occurs
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

v_log=$sc_tmp.log
echo -e "\n# Clearing ARP cache for non-reachable IP in range '192.168.122.*' :" 
arp -n | grep virbr0 | grep 192.168.122 > $v_log && (
	cat $v_log
	for i in `awk '{ print $1 }' $v_log`; do
		ping -c 1 $i > /dev/null || (
			echo -e "## Clearing for $i"
			sh -xc "sudo arp -d $i"
			)
	done
	)

echo -e "\n# Current ARP cache status"
arp -n | egrep -v 'docker0|lxdbr0|wlp0s20f3|169.254.169'


