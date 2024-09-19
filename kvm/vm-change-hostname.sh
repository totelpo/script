#!/bin/bash
# totel 20240909 Script to setup VM environment variables
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use(){
          echo "
 DESC: This is a template script
USAGE:"
  cat << EOF | column -t
ANSIBLE_HOST=s091 NEW_HOSTNAME=el9-091 $sc_name1
EOF
exit
}

if [ "$1" = "h" ]; then f_use; fi

if [ ! -z "${ANSIBLE_HOST}" -a ! -z "${NEW_HOSTNAME}" ]; then
  f-marker $sc_name1 ANSIBLE_HOST=${ANSIBLE_HOST=} NEW_HOSTNAME=${NEW_HOSTNAME}

  cat << EOF > ${sc_tmp}.yaml
---
- name: Change hostname of a serve
  hosts: ${ANSIBLE_HOST}
  become: true

  tasks:
    - name: Set the hostname
      hostname:
        name: "${NEW_HOSTNAME}"

    - name: Ensure /etc/hostname contains the new hostname
      copy:
        content: "{{ inventory_hostname }}"
        dest: /etc/hostname

    - name: Update /etc/hosts file
      lineinfile:
        path: /etc/hosts
        regexp: '^127.0.1.1'
        line: "127.0.1.1 {{ inventory_hostname }}"

    - name: Reboot the server to apply the new hostname
      reboot:
        msg: "Rebooting to apply hostname change"
        reboot_timeout: 600
EOF

  sh -xc "ansible-playbook ${sc_tmp}.yaml"
else
  f_use
fi
