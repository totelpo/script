f-check-if-dir-is-empty(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3" 
	fi_dir_name=$1
	[ "$(ls -A $fi_dir_name)" ]
	fx_check_if_dir_is_empty=$?
	if [ $fx_check_if_dir_is_empty -eq 0 ]; then
		echo -e "\nDirectory $fi_dir_name is NOT empty.\n"
		ls -lhA $fi_dir_name
		exit
	fi
	echo -e "Passed."
}
