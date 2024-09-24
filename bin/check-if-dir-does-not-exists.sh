#!/bin/bash
# DESC : Ensure that folder does not exists
# totel 20240925 v1.0

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
  echo "
USAGE:"
  cat << EOF | column -t
DIR_NAME=/vm/kvm/somedir $sc_name1
EOF
exit 1
}

if [ ! -z "${DIR_NAME}" ]; then # if required variables are not empty
  MARKER_WIDTH=$((MARKER_WIDTH*75/100)) f-marker $sc_name1 $p_all_input_parameters
else
  f_use
fi

if [ -d "${DIR_NAME}" ]; then
  echo "FAILED. Directory (${DIR_NAME}) exists."
  exit 1
fi
echo -e "PASSED."
