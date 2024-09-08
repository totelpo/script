f-check-if-dir-exists(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3"
	fi_dir_name=$1
	ls -lhd $fi_dir_name
	fx_check_if_dir_exists=$?
	if [ $fx_check_if_dir_exists -eq 0 ]; then
		echo -e "\nFAILED : Directory $fi_dir_name already exists.\n"
		exit 1
	fi
	echo -e "PASSED.\n"
}
