#!/bin/bash
# totel 20240918 v1.0 wait-kvm-ip.sh

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
  echo "
# USAGE:"
  cat << EOF | column -t
VM=el9-090 WAIT_MINUTE=7 $sc_name1
EOF
exit 1
}

# Variables with default values
CHECK="${CHECK:="y"}" 

if [ ! -z "${VM}" -a ! -z "${WAIT_MINUTE}" ]; then
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker $sc_name1 VM=${VM} WAIT_MINUTE=${WAIT_MINUTE}

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
      echo -e "\n[FAILED] Timeout of $v_timeout seconds reached.\n"
      exit 1
    fi
  done
  echo -e "\nWaited ${v_timeout1} seconds (about $((v_timeout1/60)) minutes)."
  echo -e "\n[SUCCESS] VM ${VM} has acquired IP $r_ip"
  echo
else
  echo "\nEmpty variable : VM=${VM} | WAIT_MINUTE=${WAIT_MINUTE}\n"
  f_use
fi
