f-check-if-ip-is-reachable(){
  IP="${IP:=$1}"
  EXIT="${EXIT:=y}"
  MARKER="${MARKER:=n}"
	if [ "${MARKER}" = "y" ]; then
    f-marker "${FUNCNAME[0]}"
  fi
	ping -c 1 ${IP} > /dev/null
	fx_check_if_ip_is_reachable=$?
	if [ $fx_check_if_ip_is_reachable -gt 0 ]; then
    f-message ERROR "${IP} is not reachable"
		if [ "${EXIT}" = "y" ]; then
			exit 1
		fi
	fi
}
