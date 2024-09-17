#!/bin/bash
# totel 20240913 Convert from bash function to bash script : mv 'mv function/f-check-if-ip-in-used.sh bin/check-if-ip-in-used.sh'

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: This is a template script
USAGE:"
  cat << EOF | column -t
IP=192.168.122.90 $sc_name1
EOF
exit 1
}

if [ ! -z "${IP}" ]; then # if required variables are not empty
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker IP=${IP} $sc_name1
else
  f_use
fi

ping -c 1 ${IP} > /dev/null
v_check_if_ip_in_used=$?
if [ ${v_check_if_ip_in_used} -eq 0 ]; then
  echo -e "IP ${IP} is alive."
  exit 1
fi
echo -e "PASSED."
