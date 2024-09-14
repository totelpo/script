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

if [ $# -lt 2 ]; then
	f_use
fi

p_yaml="$1"; p_yaml=${p_yaml:=el7-ps57-install.yaml} # default value
p_host="$2"; p_host=${p_host:=c7n77} # default value
p_hosts_file="$3"; p_hosts_file=${p_hosts_file:=/etc/ansible/hosts} # default value

f-marker $sc_name1 $(basename ${p_yaml})

set -e
if [ ! -f $p_yaml ]; then
	ls -lh $p_yaml
fi
if [ ! -f $p_hosts_file ]; then
	ls -lh $p_hosts_file
fi
set +e

v_tmp_yaml=${TMPDIR}/${sc_name2}-$(basename $p_yaml)
sh -xc "cp ${p_yaml} ${v_tmp_yaml}"
echo
sed -i "s/^  hosts:.*/  hosts: $p_host/" ${v_tmp_yaml}
sh -xc "ansible-playbook ${v_tmp_yaml} -i $p_hosts_file --become"
