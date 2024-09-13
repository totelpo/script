f-check-if-similar-vm-exists-based-on-ip(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3"
	fi_ip=$1
	v_ip_last=`echo $fi_ip | awk -F'.' '{ print $NF }'`
	v_ip_last_padded=`printf "%03d" $v_ip_last`
	virsh list --all | grep "\-$v_ip_last_padded" 2> /dev/null
	fx_check_if_similar_vm_exists_based_on_ip=$?
	if [ $fx_check_if_similar_vm_exists_based_on_ip -eq 0 ]; then
		echo -e "\nVM $fi_vm_name has similar VM/s based on IP $fi_ip\n"
		exit
	fi
	echo -e "PASSED."
}
