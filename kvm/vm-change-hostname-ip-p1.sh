#!/bin/bash
sc_name=$0

source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh
# f-marker $sc_name1 $p_all_input_parameters  # move after all the checks

p_os_variant="$1";   p_os_variant=${p_os_variant:=el7} # default value
p_vm="$2"     ; p_vm=${p_vm:=c7n74}           # default value
p_ip_new="$3" ; p_ip_new=${p_ip_new:=192.168.122.74}      # default value

f_use(){
	echo "
$sc_name1  P_OS_VARIANT  P_VM   P_IP_NEW
$sc_name1  el7           c7n74  192.168.122.74
"
}

f-ssh-extra-arg-conf ${p_os_variant}

if [ $# -eq 3 ]; then
	f-check-allowed-values "Supported OS" "rhel5 rhel6 rhel7 rhel8 u16 u22 u20 el5 el6 el7 el8 el9 o9" ${p_os_variant} " "
	set -e
	arp -an > ${sc_temp}.arp
	virsh domiflist $p_vm > ${sc_temp}.domiflist
	v_mac=`grep ' bridge ' ${sc_temp}.domiflist | awk '{ print $5 }'`
	v_ip=`grep "$v_mac" ${sc_temp}.arp | head -1 | awk '{ print $2}' | sed 's/(//; s/)//'`
	
	echo "$v_ip : Checking connectivity"
	set +e
  f-ssh-ensure-connectivity $v_ip
	v_exit_status=$?
	
	echo
	if [ $v_exit_status -eq 0 ]; then
		set -e
		cd $sc_dirname/
		vm-copy-scripts.sh $v_ip
		v_cmd1="(. ~/.bashrc; change-hostname.sh ${p_os_variant} $p_vm) 2>&1 &> ~/change-hostname-1.log &"
    # IMPORTANT : copy change-ip.sh to local as it will hang if its nfs location was unmounted.
		v_cmd2="(. ~/.bashrc; change-ip.sh  ${p_os_variant} $p_ip_new ) 2>&1 &> ~/change-ip-1.log &"
    f_ssh_cmd(){
      v_cmd="$1"
		  echo -e "### Executing :\n### ssh -i /home/totel/.ssh/id_rsa_kvm $v_ssh_extra root@$v_ip '$v_cmd'"
		  ssh -i /home/totel/.ssh/id_rsa_kvm $v_ssh_extra root@$v_ip "$v_cmd"
    }
    f_ssh_cmd "$v_cmd1"
    f_ssh_cmd "$v_cmd2"
    if [ "$p_ip_new" != "0" ]; then
		  f-ip-wait-to-be-reachable $p_ip_new
      f-ssh-ensure-connectivity $p_ip_new
    else
      vm-list.sh $p_vm
    fi
		echo
	else
		echo Cannot passwordless connect 
		exit 1
	fi
else
	f_use
fi
