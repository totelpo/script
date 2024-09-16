#!/bin/bash
# totel 20240913 Wait until IP and port is open

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: Wait until IP is SSH able
USAGE:"
  cat << EOF | column -t
IP=192.168.122.90 PORT=22 WAIT_MINUTE=7 $sc_name1
EOF
exit
}

if [ ! -z "${IP}" -a ! -z "${PORT}" -a ! -z "${WAIT_MINUTE}" ]; then
  f-marker $sc_name1 IP=${IP} PORT=${PORT} WAIT_MINUTE=${WAIT_MINUTE}
else
  f_use
fi

v_timeout=$((WAIT_MINUTE*60))
v_timeout1=0
v_sleep=20

echo -e "\nWaiting for ${IP} port ${PORT} to open. Check interval is ${v_sleep} seconds. Max WAIT_MINUTE=${WAIT_MINUTE}" 
until nc -zv ${IP} ${PORT} 2> /dev/null; do
  printf "."
  sleep $v_sleep
  v_timeout1=$((v_timeout1+v_sleep))
  if [ ${v_timeout1} -gt ${v_timeout} ]; then
    echo -e "\nIP ${IP}:${PORT} is still NOT open after ${WAIT_MINUTE} minute timeout reachead. Please check the server.\n"
    exit 1
  fi
done
echo -e "\nWaited ${v_timeout1} seconds (about $((v_timeout1/60)) minutes)."
echo -e "\n${IP} port ${PORT} is now open.\n"

