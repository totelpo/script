f-check-if-ip-in-used(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2"
	fi_ip=$1
	fi_exit="$2"; fi_exit=${fi_exit:=y}
	ping -c 1 $fi_ip > /dev/null
	fx_check_if_ip_in_used=$?
	if [ $fx_check_if_ip_in_used -eq 0 ]; then
		echo -e "IP $fi_ip is alive."
		if [ "$fi_exit" = "y" ]; then
			exit 1
		fi
	fi
	echo -e "PASSED."
}
