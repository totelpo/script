#!/bin/bash
# DESC: This is a template script
# totel 20240913 Some info here
# totel 20240816 v2.0 Change input from Positional Parameters to Environment Variable Assignment (Inline Export)

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

if [ ! -z "${VM}" ]; then # if required variables are not empty
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker VM=${VM} $sc_name1
else
  # Ensure required variables are defined
  echo "
FAILED: Empty variables found.
VM=${VM}"
  f_use
fi

v_vm_id=`echo "${VM}" | cut -d'-' -f2 `
virsh list --all | grep "\-$v_vm_id"
if [ $? -eq 0 ]; then
  echo -e "\nFAILED : VM exists with similar ID $v_vm_id\n"
  exit 1
else
  echo "PASSED."
fi
