f-change-ip-nmcli(){
  # This is called by change-ip.sh
  if [ ! -z "${NEW_IP}" ]; then # if required variables are not empty
    f-marker ${FUNCNAME[0]}
    set +e  ### disable exit-on-error
    v_conn_dev=`nmcli -t -f NAME,DEVICE conn | grep ":${v_dev}"`   # nmcli conn show
    v_conn_name=`echo "$v_conn_dev" | cut -d':' -f1`
    # Rename connection
  
    # Unmount all NFS 
    set +e
    f-umount-all-nfs
    set -e
    echo
    # set IP
    f-marker "Update IP settings"
    sudo bash -xc "
nmcli connection modify "${v_conn_name}" ipv4.method manual IPv4.address ${NEW_IP}/24
nmcli connection modify "${v_conn_name}" ipv4.gateway 192.168.122.1
nmcli connection modify "${v_conn_name}" ipv4.dns 192.168.122.1 +ipv4.dns 8.8.8.8
nmcli connection up "${v_conn_name}"   ### restart device
sleep 2
  "
    f-marker "Mount all unmounted NFS"
    sudo bash -xc "mount -a"                    ### remount all fstab entries
  
    if [ ! "${v_dev}" = "${v_conn_name}" ]; then 
      f-marker "Make device and connection name the same."
      bash -xc "nmcli con mod "${v_conn_name}" con-name ${v_dev}" ;
    fi
  
    f-marker "Gather Info 1"
    set +e
    bash -xc "egrep 'BOOTPROTO|IPADDR|PREFIX|GATEWAY|DNS|NETMASK' /etc/sysconfig/network-scripts/ifcfg-${v_dev}"
    set -e
    echo ; 
    bash -xc "
nmcli -t -f IP4 connection show ${v_conn_name}
nmcli con show
  "
    echo
  
  fi
}
