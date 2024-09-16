#!/bin/bash
# DESC: Run ansible script
# totel 20220810 v1.0
# totel 20240816 v2.0 Change input from Positional Parameters to Environment Variable Assignment (Inline Export)
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
  (
  echo "
# USAGE :
cd ${ANSIBLE_YAML_DIR}/sample"
cat << EOF 
YAML=el-only-assert.yaml  ANSIBLE_HOST=s090      $sc_name1 
YAML=el-only-fail.yaml    ANSIBLE_HOST=s090      $sc_name1 
YAML=yum.yaml             ANSIBLE_HOST=s090      $sc_name1 
YAML=localhost.yaml       ANSIBLE_HOST=localhost EXTRA_ARGS=' ' $sc_name1 
EOF
) | sed "s|$HOME|~|g"
exit
}

HOSTS_FILE=${HOSTS_FILE:=/etc/ansible/hosts} # default value
EXTRA_ARGS=${EXTRA_ARGS:-"--become"} # default value

if [ ! -z "${YAML}" -a ! -z "${ANSIBLE_HOST}" ]; then # if required variables are not empty
  MARKER_WIDTH=105 f-marker $sc_name1 ${ANSIBLE_HOST} $(basename ${YAML})
else
    # Ensure required variables are defined
  echo "
FAILED: Empty variables found.
ANSIBLE_HOST=${ANSIBLE_HOST} | YAML=${YAML} "
	f_use
fi

set -e
if [ ! -f ${YAML} ]; then
	ls -lh ${YAML}
fi
if [ ! -f ${HOSTS_FILE} ]; then
	ls -lh ${HOSTS_FILE}
fi

echo 
for i_yaml in ${YAML} $(grep '^      include_tasks: ' ${YAML} | awk '{ print $NF }') 
do
  v_tmp_yaml=${TMPDIR}/aw-$(basename ${i_yaml})
  sh -xc "cp ${i_yaml} ${v_tmp_yaml}"
  bash -xc "sed -i 's/^  hosts:.*/  hosts: ${ANSIBLE_HOST}/' ${v_tmp_yaml}"
done

echo
sh -xc "
cd ${TMPDIR}
ansible-playbook aw-$(basename ${YAML}) -i ${HOSTS_FILE} ${EXTRA_ARGS}
"

