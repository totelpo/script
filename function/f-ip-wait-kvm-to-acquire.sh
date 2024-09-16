f-ip-wait-kvm-to-acquire(){
  f-marker ${FUNCNAME[0]} VM=${VM} WAIT_MINUTE=${WAIT_MINUTE}
  if [ ! -z "${VM}" -a ! -z "${WAIT_MINUTE}" ]; then
    v_timeout=$((WAIT_MINUTE*60))
    echo -e "\nWaiting for ${VM} to startup and acquire an IP address. WAIT_MINUTE=${WAIT_MINUTE} " 
    v_timeout0=0
    v_sleep=5
    VM=${VM}   f-get-kvm-ip > /dev/null; v_ip=$r_ip
    while [ "$v_ip" = "" ]; do
      VM=${VM} f-get-kvm-ip > /dev/null; v_ip=$r_ip
      printf "."
      sleep $v_sleep
      v_timeout0=$((v_timeout0+v_sleep))
      if [ $v_timeout0 -gt $v_timeout ]; then
        echo -e "\nTimeout of $v_timeout seconds reached.\n"
        exit 1
      fi
    done
    echo -e "\nVM ${VM} has acquired IP $r_ip"
    echo
  else
    echo "\nEmpty variable : VM=${VM} | WAIT_MINUTE=${WAIT_MINUTE}\n"
  fi
}
  
