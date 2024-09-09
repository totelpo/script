#!/bin/bash
# totel 20240909 add to github
sc_name=$0
set -e
source /home/${SUDO_USER}/script/env/env_vm_os_admin.sh
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh
set +e

f_use(){
	echo "
USAGE :
./$sc_name1 OS  NEW_HOSTNAME
./$sc_name1 el9 el9-091
"
	exit
}

p_os="$1";   p_os=${p_os:=el7} # default value
p_new_hostname="$2"

v_log=${sc_tmp}.log

if [ $# -eq 2 ]; then
  f-marker $sc_name1 $p_all_input_parameters  # move after all the checks
	v_old_hostname="`hostname -s`"
	if [ "$v_old_hostname" = "$p_new_hostname" ]; then
		echo -e "\nNo hostname changed. Old and new hostname are the same.\n"
		exit
	fi

	f_hostnamectl(){
		f-marker ${FUNCNAME[0]}
	        sh -xc "hostnamectl set-hostname $p_new_hostname"  # remove .kvmpo.local to avoid dns search which slow down network search
	}

	f_hostname_script(){
		f-marker ${FUNCNAME[0]}
		sed -i "s/^HOSTNAME=.*/\HOSTNAME=$p_new_hostname.kvmpo.local/"   /etc/sysconfig/network
		hostname $p_new_hostname.kvmpo.local
	}

	f_ubuntu_hostnamectl(){
		f-marker ${FUNCNAME[0]}
	        sh -xc "hostnamectl set-hostname $p_new_hostname.kvmpo.local"
	}

	echo -e "\n# Logging to : ${v_log}\n"
	set -e
	if   [ "$p_os" = "el7" -o "$p_os" = "el8" -o "$p_os" = "el9" ]; then
		f_hostnamectl
	elif [ "$p_os" = "el5" -o "$p_os" = "el6" ]; then
		f_hostname_script
	elif [ "$p_os" = "u16" -o "$p_os" = "u20" -o "$p_os" = "u22" ]; then
		f_ubuntu_hostnamectl
	else 
		echo "$p_os : OS not supported"
	fi 2>&1 &> ${v_log}
else
	f_use
fi
	
