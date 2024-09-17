f-check-if-similar-vm-id-exist(){
        f-message EXECUTING "${FUNCNAME[0]} $1 $2"
	fi_vm_name=$1
	v_vm_id=`echo "$fi_vm_name" | cut -d'-' -f2 `
	virsh list --all | grep "\-$v_vm_id"
	if [ $? -eq 0 ]; then
		echo -e "\nFAILED : VM exists with similar ID $v_vm_id\n"
		exit 1
	else
		echo "PASSED."
	fi
}
