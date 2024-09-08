f-check-if-vm-exists(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3"
	fi_vm_name=$1
	virsh list --all | grep " $fi_vm_name "
	fx_check_if_vm_exists=$?
	if [ $fx_check_if_vm_exists -eq 0 ]; then
		echo -e "\nFAILED : VM $fi_vm_name already exists.\n"
		exit
	fi
	echo -e "PASSED."
}
