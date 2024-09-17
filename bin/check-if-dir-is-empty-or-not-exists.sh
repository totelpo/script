#!/bin/bash
# totel 20240913 Convert from function to shell script : 'mv function/f-check-if-dir-is-empty.sh bin/check-if-dir-is-empty.sh'

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: This is a template script
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

if [ ! -d "${DIR_NAME}" ]; then
  echo "Directory does not exist." > /dev/null
elif [ -z "$(ls -A "${DIR_NAME}")" ]; then
  echo "Directory is empty."  > /dev/null
else
  echo "FAILED. Directory (${DIR_NAME}) exists and is not empty."
  exit 1
fi
echo -e "PASSED."
