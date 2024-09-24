#!/bin/bash
# DESC: Change VM NEW_IP
# totel 20240913 Some info here
# totel 20240816 v2.0 Change input from Positional Parameters to Environment Variable Assignment (Inline Export)

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
  echo "
# USAGE:"
  cat << EOF | column -t
VM=el9-091 NEW_IP=192.168.122.91 $sc_name1
VM=el8-081 NEW_IP=192.168.122.81 $sc_name1
EOF
exit 1
}

if [ ! -z "${VM}" -a ! -z "${NEW_IP}" ]; then # if required variables are not empty
  f-marker VM=${VM} NEW_IP=${NEW_IP} $sc_name1 
else
  # Ensure required variables are defined
  echo "
FAILED: Empty variables found.
VM=${VM} | NEW_IP=${NEW_IP} "
  f_use
fi

VM=${VM} f-get-kvm-ip               > /dev/null # returns $r_ip
IP=$r_ip      f-ip-to-ansible-host  > /dev/null # returns $r_ansible_host
v_ansible_host1=${r_ansible_host}
IP=${NEW_IP} f-ip-to-ansible-host   > /dev/null # returns $r_ansible_host
v_ansible_host2=${r_ansible_host}

if [ "${NEW_IP}" = "${r_ip}" ]; then
  echo -e "\nOld(${r_ip}) and new(${NEW_IP}) IP are the same. No change needed."
  exit
fi

set -e

cd /github/totelpo/script/ansible/yaml
cp -v change-ip.yaml ${TMPDIR}/
cd ${TMPDIR}/
line1=$(nl -ba change-ip.yaml | grep '  hosts:' | sed -n '1p' | awk '{ print $1 }')
line3=$(nl -ba change-ip.yaml | grep '  hosts:' | sed -n '3p' | awk '{ print $1 }')
sed -i "
 ${line1}s/^  hosts:.*/  hosts: ${v_ansible_host1}/
;${line3}s/^  hosts:.*/  hosts: ${v_ansible_host2}/
;s/\(new_ip_address:\).*/\1 ${NEW_IP}/
;s/\(cur_ip_address:\).*/\1 ${r_ip}/
" change-ip.yaml

ansible-playbook change-ip.yaml

set +e

f-marker "VM status"
vm-list.sh | egrep " ${VM} |^ Id"
