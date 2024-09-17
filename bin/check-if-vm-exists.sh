#!/bin/bash
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: Check if VM exists
USAGE:"
  cat << EOF | column -t
VM=el9-090 $sc_name1
EOF
exit
}

if [ ! -z "${VM}" ]; then # if required variables are not empty
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker $sc_name1 $p_all_input_parameters
else
  f_use
fi

virsh list --all | grep " ${VM} "
fx_check_if_vm_exists=$?
if [ $fx_check_if_vm_exists -eq 0 ]; then
  echo -e "\nFAILED : VM ${VM} already exists.\n"
  exit 1
fi
echo -e "PASSED."
