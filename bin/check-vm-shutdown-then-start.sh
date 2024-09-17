#!/bin/bash
# totel 20240913 Start VM after OS install auto shutdown

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: Start VM after OS install auto shutdown
USAGE:"
  cat << EOF | column -t
IP=192.168.122.90 PORT=22 WAIT_MINUTE=7 $sc_name1
EOF
exit
}

if [ ! -z "${VM}" -a ! -z "${WAIT_MINUTE}" ]; then
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker $sc_name1 $p_all_input_parameters
else
  f_use
fi

v_timeout=$((WAIT_MINUTE*60))
v_timeout1=0
v_sleep=20

echo -e "\nWaiting for ${VM} to auto shutdown after OS install before starting up. Check interval is ${v_sleep} seconds. Max WAIT_MINUTE=${WAIT_MINUTE}" 
until ( virsh list --all | grep " ${VM} " | grep 'shut off' 2>&1 &> /dev/null ); do
  printf "."
  sleep $v_sleep
  v_timeout1=$((v_timeout1+v_sleep))
  if [ ${v_timeout1} -gt ${v_timeout} ]; then
    echo -e "\n${VM} is still up after ${WAIT_MINUTE} minute timeout reachead. Please check the server with command :\nvirsh console ${VM}"
    exit 1
  fi
done
echo -e "\nWaited ${v_timeout1} seconds (about $((v_timeout1/60)) minutes).\n"
virsh list --all | grep " ${VM} "
echo
sh -xc "virsh start ${VM}"

