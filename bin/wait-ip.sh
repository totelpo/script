#!/bin/bash
# totel 20240918 Wait until IP is up or down

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: Wait until IP is up or down
USAGE:"
  cat << EOF | column -t
IP=192.168.122.91 WAIT_FOR=up   $sc_name1
IP=192.168.122.91 WAIT_FOR=down $sc_name1
EOF
exit
}

if [ ! -z "${IP}" -a ! -z "${WAIT_FOR}" ]; then
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker $sc_name1 IP=${IP} WAIT_FOR=${WAIT_FOR}
else
  f_use
fi

WAIT_MINUTE="${WAIT_MINUTE:=7}"
SLEEP="${SLEEP:=5}"

v_timeout=$((WAIT_MINUTE*60))
v_timeout1=0

f_main(){
  printf "."
  sleep $SLEEP
  v_timeout1=$((v_timeout1+SLEEP))
  if [ ${v_timeout1} -gt ${v_timeout} ]; then
    echo -e "\n[FAILED] IP ${IP} is still not ${WAIT_FOR} after ${WAIT_MINUTE} minute timeout reachead. Please check the server.\n"
    exit 1
  fi
}

echo -e "\nWaiting for IP ${IP} to be ${WAIT_FOR}. Check interval SLEEP=${SLEEP} second per dot(.) and max WAIT_MINUTE=${WAIT_MINUTE}"
if   [ "${WAIT_FOR}" = "up" ]; then
  until  (ping -c 1 ${IP} > /dev/null); do
    f_main
  done
elif [ "${WAIT_FOR}" = "down" ]; then
  until !(ping -c 1 ${IP} > /dev/null); do
    f_main
  done
else
  echo -e "\n[ERROR] Invalid value WAIT_FOR=${WAIT_FOR}\n"
  f_use
fi
echo -e "\nIP ${IP} is now ${WAIT_FOR}.\n"

