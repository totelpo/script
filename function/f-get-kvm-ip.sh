f-get-kvm-ip(){
	i_vm_name="$1"; i_vm_name=${i_vm_name:=$p_vm_name}
	i_verbose=$2
	v_mac=`virsh domiflist $i_vm_name | awk '{ print $5 }' | grep . | sed '1d'`
	r_ip=`arp -an | grep "$v_mac" | awk '{ print $2}' | sed 's/(//; s/)//'`
	if [ "$i_verbose" = v ]; then
		echo -e "# r_ip = $r_ip"
	fi
}

