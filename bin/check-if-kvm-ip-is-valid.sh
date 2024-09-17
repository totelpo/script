#!/bin/bash
# totel 20240913 Convert function f-check-if-kvm-ip-is-valid to bash script check-if-kvm-ip-is-valid.sh
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: Check if IP is valid. Must be 192.168.122.[2-254]
USAGE:"
  cat << EOF | column -t
IP=192.168.122.90 $sc_name1
EOF
exit
}

if [ ! -z "${IP}" ]; then # if required variables are not empty
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker IP=${IP} $sc_name1
else
  f_use
fi

v_grep=192.168.122
echo ${IP} | grep "$v_grep\." > /dev/null
fx_check_if_kvm_ip_is_valid=$?
if [ $fx_check_if_kvm_ip_is_valid -gt 0 ]; then
  echo -e "\nFAILED. IP ${IP} is invalid. Must be $v_grep.X\n"
  exit 1
fi
v_ip_last=`echo ${IP} | awk -F'.' '{ print $NF }'`
if ! [ $v_ip_last -gt 1 -a $v_ip_last -lt 255 ]; then
  echo -e "\nFAILED. IP ${IP} is invalid. Must be $v_grep.[2-254]\n"
  exit 1
fi
echo -e "PASSED."

