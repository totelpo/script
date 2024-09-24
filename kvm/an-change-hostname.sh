#!/bin/bash
sc_name=$0

source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: Change server hostname
USAGE:"
  cat << EOF
VM=el9-091 $sc_name1
VM=el9-091 NEW_HOSTNAME=node1 $sc_name1
EOF
exit 1
}

if [ ! -z "${VM}" ]; then # if required variables are not empty
  f-marker VM=${VM} $sc_name1 
else
  # Ensure required variables are not empty (that is already declared in bashrc).
  echo -e "\nFAILED: Empty variables found.\nOS=${OS} | ANSIBLE_HOST=${ANSIBLE_HOST} | NEW_HOSTNAME=${NEW_HOSTNAME}"
  f_use
fi

NEW_HOSTNAME="${NEW_HOSTNAME:=${VM}}"

VM=${VM} f-get-kvm-ip          > /dev/null # returns $r_ip
IP=$r_ip f-ip-to-ansible-host  > /dev/null # returns $r_ansible_host


(
ansible-hosts-common.sh 
cat << EOF
${r_ansible_host} ansible_host=${r_ip}
EOF
) > ${TMPDIR}/hosts 
set -e

cat << EOF > $sc_tmp.yaml
-
  name: Change hostname on RHEL server
  hosts: ${r_ansible_host}
  become: yes
  tasks:
    - name: Set the system hostname
      ansible.builtin.hostname:
        name: ${NEW_HOSTNAME}

    - name: Ensure the hostname persists across reboots (for RHEL 7/8/9)
      ansible.builtin.command:
        cmd: hostnamectl set-hostname ${NEW_HOSTNAME}
      when: 
        - ansible_facts['os_family'] == 'RedHat'
        - ansible_facts['distribution_major_version'] | int >= 7

    - name: Update /etc/hosts file with the new hostname
      ansible.builtin.lineinfile:
        path: /etc/hosts
        regexp: '^127\.0\.0\.1'
        line: "127.0.0.1   localhost ${NEW_HOSTNAME}"
        state: present
        backrefs: yes
EOF

bash -xc "ansible-playbook -i ${TMPDIR}/hosts $sc_tmp.yaml"
f-marker Verify new hostname
bash -xc "ssh ${r_ip} hostname"
