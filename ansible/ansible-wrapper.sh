#!/bin/bash
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
# DESC: totel 2022-08-10
# USAGE: Run Asnible script 
pwd
  echo "
$sc_name1 YAML_FILE              ANSIBLE_HOST
$sc_name1 el7-ps57-install.yaml  c7n77
echo
" | sed "s|$HOME|~|g"
ls *.yaml | head
exit
}

HOSTS_FILE=${HOSTS_FILE:=/etc/ansible/hosts} # default value

f-marker $sc_name1 $(basename ${YAML})

if [ ! -z "${YAML}" -a ! -z "${ANSIBLE_HOST}" ]; then # if required variables are not empty
  MARKER_WIDTH=105 f-marker $sc_name1 YAML=$(basename ${YAML}) ANSIBLE_HOST=$(basename ${ANSIBLE_HOST})
else
	f_use
fi

set -e
if [ ! -f ${YAML} ]; then
	ls -lh ${YAML}
fi
if [ ! -f ${HOSTS_FILE} ]; then
	ls -lh ${HOSTS_FILE}
fi
set +e

v_tmp_yaml=${TMPDIR}/${sc_name2}-$(basename ${YAML})
sh -xc "cp ${YAML} ${v_tmp_yaml}"
echo
sed -i "s/^  hosts:.*/  hosts: ${ANSIBLE_HOST}/" ${v_tmp_yaml}
sh -xc "ansible-playbook ${v_tmp_yaml} -i ${HOSTS_FILE} --become"

