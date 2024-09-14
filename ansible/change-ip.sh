#!/bin/bash
sc_name=$0

source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: Change server hostname
USAGE:"
  cat << EOF | column -t
OS=el9 HOST=s090 NEW_IP=192.168.122.91 $sc_name1
EOF
exit 1
}

if [ ! -z "${OS}" -a ! -z "${HOST}" -a ! -z "${NEW_IP}" ]; then # if required variables are not empty
  f-marker $sc_name1 ${OS} ${HOST} ${NEW_IP}
else
  # Ensure required variables are not empty (that is already declared in bashrc).
  echo -e "\nFAILED: Empty variables found.\nOS=${OS} | HOST=${HOST} | NEW_IP=${NEW_IP}"
  f_use
fi

set -e
check-os-support.sh

v_yaml=yaml/${sc_name2}.yml
cp -v ${v_yaml} ${sc_tmp}.yml

sed -i "
 s/^  hosts: .*/  hosts: ${HOST}/
;s/NEW_IP_ADDRESS/${NEW_IP}/
" ${sc_tmp}.yml

bash -xc "ansible-playbook ${sc_tmp}.yml --become"
