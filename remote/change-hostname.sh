#!/bin/bash
# totel 20240909 add to github
sc_name=$0

if [ ! -z "${SUDO_USER}" ]; then
  echo "
This script must be properly executed with sudo command. Example :
sudo bash -c 'OS=el9 NEW_HOSTNAME=el9-091  $(basename ${sc_name}) '
"
  exit 1
fi
set -e
source /home/${SUDO_USER}/script/env/env_vm_os_admin.sh
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh
set +e

f_use(){
	echo "
USAGE :
OS=el9 NEW_HOSTNAME=el9-091 ./$sc_name1 OS  NEW_HOSTNAME
"
	exit
}

p_new_hostname="$2"

v_log=${sc_tmp}.log

if [ $# -eq 2 ]; then
  f-marker $sc_name1 $p_all_input_parameters  # move after all the checks
	v_old_hostname="`hostname -s`"
	if [ "${v_old_hostname}" = "${NEW_HOSTNAME}" ]; then
		echo -e "\nNo hostname changed. Old and new hostname are the same.\n"
		exit
	fi

	f_hostnamectl(){
		f-marker ${FUNCNAME[0]}
	        sh -xc "hostnamectl set-hostname ${NEW_HOSTNAME}"  # remove .kvmpo.local to avoid dns search which slow down network search
	}

	f_hostname_script(){
		f-marker ${FUNCNAME[0]}
		sed -i "s/^HOSTNAME=.*/\HOSTNAME=${NEW_HOSTNAME}.kvmpo.local/"   /etc/sysconfig/network
		hostname ${NEW_HOSTNAME}.kvmpo.local
	}

	f_ubuntu_hostnamectl(){
		f-marker ${FUNCNAME[0]}
	        sh -xc "hostnamectl set-hostname ${NEW_HOSTNAME}.kvmpo.local"
	}

	echo -e "\n# Logging to : ${v_log}\n"
	set -e
	if   [ "${OS}" = "el7" -o "${OS}" = "el8" -o "${OS}" = "el9" ]; then
		f_hostnamectl
	elif [ "${OS}" = "el5" -o "${OS}" = "el6" ]; then
		f_hostname_script
	elif [ "${OS}" = "u16" -o "${OS}" = "u20" -o "${OS}" = "u22" ]; then
		f_ubuntu_hostnamectl
	else 
		echo "${OS} : OS not supported"
	fi 2>&1 &> ${v_log}
else
	f_use
fi
	
