#!/bin/bash
sc_name=$0

source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: Change server hostname
USAGE:"
  cat << EOF | column -t
OS=el9 HOST=s090 NEW_HOSTNAME=el9-090-s1 $sc_name1
EOF
exit 1
}

if [ ! -z "${OS}" -a ! -z "${HOST}" -a ! -z "${NEW_HOSTNAME}" ]; then # if required variables are not empty
  f-marker $sc_name1 ${OS} ${HOST} ${NEW_HOSTNAME}
else
  # Ensure required variables are not empty (that is already declared in bashrc).
  echo -e "\nFAILED: Empty variables found.\nOS=${OS} | HOST=${HOST} | NEW_HOSTNAME=${NEW_HOSTNAME}"
  f_use
fi

set -e
check-os-support.sh

cat << EOF > $sc_tmp.yaml
---
- name: Change hostname on RHEL server
  hosts: ${HOST}
  tasks:
    - name: Set the system hostname
      ansible.builtin.hostname:
        name: ${NEW_HOSTNAME}

    - name: Ensure the hostname persists across reboots (for RHEL 7/8/9)
      ansible.builtin.command:
        cmd: hostnamectl set-hostname ${NEW_HOSTNAME}
      when: ansible_facts['os_family'] == 'RedHat'

    - name: Update /etc/hosts file with the new hostname
      ansible.builtin.lineinfile:
        path: /etc/hosts
        regexp: '^127\.0\.0\.1'
        line: "127.0.0.1   localhost ${NEW_HOSTNAME}"
        state: present
        backrefs: yes
EOF

bash -xc "ansible-playbook $sc_tmp.yaml --become"
