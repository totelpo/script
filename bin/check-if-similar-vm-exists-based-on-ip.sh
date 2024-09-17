#!/bin/bash
# totel 20240913 Convert function to script : 'mv function/f-check-if-similar-vm-exists-based-on-ip.sh bin/check-if-similar-vm-exists-based-on-ip.sh'

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: This is a template script
USAGE:"
  cat << EOF | column -t
VM=el9-090 IP=192.168.122.90 $sc_name1
EOF
exit 1
}

if [ ! -z "${IP}" ]; then # if required variables are not empty
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker IP=${IP} $sc_name1
else
  f_use
fi

v_ip_last=`echo ${IP} | awk -F'.' '{ print $NF }'`
v_ip_last_padded=`printf "%03d" $v_ip_last`
virsh list --all | grep "\-$v_ip_last_padded" 2> /dev/null
v_check_if_similar_vm_exists_based_on_ip=$?
if [ $v_check_if_similar_vm_exists_based_on_ip -eq 0 ]; then
  echo -e "\nFAILED. We have similar VM/s running based on IP ${IP}. See above output.\n"
  exit 1
fi
echo "PASSED."
