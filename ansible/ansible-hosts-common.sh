#!/bin/bash
# totel 20240914 This generates the common parameters for all ansible hosts

# Ensure required variables are not empty (that is already declared in bashrc).
if [ -z "${VM_OS_ADMIN}" -o -z "${VM_KEY_FILE}" ]; then 
  echo -e "
FAILED: Empty variables found.
VM_OS_ADMIN=${VM_OS_ADMIN}
VM_KEY_FILE=${VM_KEY_FILE}
"
  exit 1
fi

(
cat << EOF 
[all:vars]
ansible_port=22 
ansible_user=${VM_OS_ADMIN} 
ansible_become_user=root 
ansible_ssh_private_key_file=${VM_KEY_FILE}
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[vms]
EOF

for i_last in {2..2}; do
  i_pad=`printf "%03d" ${i_last}`
  echo "s${i_pad} ansible_host=192.168.122.${i_last}"
done | column -t -o' '
echo
)
