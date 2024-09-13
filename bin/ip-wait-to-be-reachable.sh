#!/bin/bash
# totel 20240913 Convert from bash function(f-ip-wait-to-be-reachable.sh) to bash script

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh
# f-marker $sc_name1 $p_all_input_parameters  # move after all the checks

f_use(){
          echo "
 DESC: Wait until IP is reachable
USAGE:"
  cat << EOF | column -t
IP=192.168.122.80 $sc_name1
EOF
exit
}

if [ ! -z "${IP}" ]; then
  f-marker $sc_name1 $p_all_input_parameters
else
  f_use
fi

v_timeout=40
v_timeout1=0
v_sleep=5

echo -e "\nWaiting for IP ${IP} to be reachable." 
until ping -c 1 ${IP} > /dev/null; do
  printf "."
  sleep $v_sleep
  v_timeout1=$((v_timeout1+v_sleep))
  if [ ${v_timeout1} -gt ${v_timeout} ]; then
    echo -e "\nIP ${IP} is still down after ${v_timeout} second timeout reachead. Please check the logs.\n"
    exit 1
  fi
done
echo -e "\nIP ${IP} is now reachable.\n"

