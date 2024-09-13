f-ip-wait-kvm-to-acquire(){
  f-marker ${FUNCNAME[0]}
  fi_vm=$1
  fi_timeout="$2"; fi_timeout=${fi_timeout:=120} # default value
  echo -e "\nWaiting for $fi_vm to startup and acquire an IP address" 
  v_timeout0=0
  v_sleep=5
  f-get-kvm-ip $fi_vm; v_ip=$r_ip
  while [ "$v_ip" = "" ]; do
    f-get-kvm-ip $fi_vm; v_ip=$r_ip
    printf "."
    sleep $v_sleep
    v_timeout0=$((v_timeout0+v_sleep))
    if [ $v_timeout0 -gt $fi_timeout ]; then
      echo -e "\nTimeout of $fi_timeout seconds reached.\n"
      exit 1
    fi
  done
  echo -e "\nVM $fi_vm has acquired IP $r_ip"
  echo
}

