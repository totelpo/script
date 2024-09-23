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

cd /github/totelpo/script/ansible/yaml/sample
cp -v change-ip-p?.yaml ${TMPDIR}/
cd ${TMPDIR}/
sed -i "
 s/^  hosts:.*/  hosts: ${v_ansible_host1}/
;s/^- hosts:.*/- hosts: ${v_ansible_host1}/
" change-ip-p1.yaml
sed -i "
 s/^  hosts:.*/  hosts: ${v_ansible_host2}/
;s/^- hosts:.*/- hosts: ${v_ansible_host2}/
" change-ip-p3.yaml

sed -i "
 s/\(new_ip_address: \).*/\1${NEW_IP}/
;s|/home/.*/script/|/home/${VM_OS_ADMIN}/script/|
" change-ip-p1.yaml
sed -i "s/\(cur_ip_address: \).*/\1${r_ip}/"   change-ip-p2.yaml

set +e

ansible-playbook change-ip-p1.yaml
ansible-playbook change-ip-p2.yaml
IP=${r_ip}   WAIT_FOR=down  wait-ip.sh
IP=${NEW_IP} WAIT_FOR=up    wait-ip.sh
ansible-playbook change-ip-p3.yaml

f-exec-command "ssh-keygen -f /home/totel/.ssh/known_hosts -R ${NEW_IP}"

f-marker "VM status"
vm-list.sh | egrep " ${VM} |^ Id"
