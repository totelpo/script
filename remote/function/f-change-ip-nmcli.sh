f-change-ip-nmcli(){
  # This is called by change-ip.sh
  if [ ! -z "${NEW_IP}" ]; then # if required variables are not empty
    f-marker ${FUNCNAME[0]}
    set +e  ### disable exit-on-error
    v_conn_dev=`nmcli -t -f NAME,DEVICE conn | grep ":${NETWORK_DEVICE}"`   # nmcli conn show
    v_conn_name=`echo "$v_conn_dev" | cut -d':' -f1`
  
    # set IP
    f-marker "Update IP settings"
    sudo bash -xc "
nmcli connection modify "${v_conn_name}" ipv4.method manual IPv4.address ${NEW_IP}/24
nmcli connection modify "${v_conn_name}" ipv4.gateway 192.168.122.1
nmcli connection modify "${v_conn_name}" ipv4.dns 192.168.122.1 +ipv4.dns 8.8.8.8
"
    f-marker "Restart connection"
    sudo bash -xc "
nmcli connection up "${v_conn_name}" 
sleep 2
"
  
    if [ ! "${NETWORK_DEVICE}" = "${v_conn_name}" ]; then 
      f-marker "Rename connection name to match device name."
      bash -xc "nmcli con mod "${v_conn_name}" con-name ${NETWORK_DEVICE}" ;
    fi
  
  fi
}
