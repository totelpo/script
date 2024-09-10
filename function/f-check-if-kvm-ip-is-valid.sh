f-check-if-kvm-ip-is-valid(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3"
	fi_ip=$1
	v_grep=192.168.122
	echo $fi_ip | grep "$v_grep."
	fx_check_if_kvm_ip_is_valid=$?
	if [ $fx_check_if_kvm_ip_is_valid -gt 0 ]; then
		echo -e "\nIP $fi_ip is invalid. Must be $v_grep.X\n"
		exit
	fi
	v_ip_last=`echo $fi_ip | awk -F'.' '{ print $NF }'`
	if ! [ $v_ip_last -gt 1 -a $v_ip_last -lt 255 ]; then
		echo -e "\nIP must be $v_grep.[2-254]\n"
		exit
	fi
	echo -e "Passed."
}

