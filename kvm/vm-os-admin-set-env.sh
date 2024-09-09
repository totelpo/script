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
IP=192.168.122.90 $sc_name1
EOF
exit
}

if [ "$1" = "h" ]; then f_use; fi

if [ ! -z "${IP}" ]; then
  f-marker $sc_name1 $p_all_input_parameters
  v_filename=env_vm_os_admin.sh
  v_src=${SCRIPT_DIR}/env/${v_filename}
  v_dest_dir=/home/${VM_OS_ADMIN}/script/env
  v_dest=${v_dest_dir}/${v_filename}
  v_ip_end=$(echo ${IP} | cut -d'.' -f 4)
  v_ansible_host=`printf "s%03d" ${v_ip_end}`

  # https://chatgpt.com/c/66debbf3-473c-8001-97eb-e146a0403ccd
  cat << EOF > ${sc_tmp}.yaml
---
- hosts: ${v_ansible_host}
  tasks:
    - name: Ensure the destination directory exists
      file:
        path: ${v_dest_dir}
        state: directory
        mode: '0755'
        owner: ${VM_OS_ADMIN}
        group: ${VM_OS_ADMIN}

    - name: Check if the file exists on the remote server
      stat:
        path: ${v_dest}
      register: file_check

    - name: Copy file to remote(${v_dest}) if it does not exist
      copy:
        src: ${v_src}
        dest: ${v_dest}
        mode: '0644'
        owner: ${VM_OS_ADMIN}
        group: ${VM_OS_ADMIN}
      when: not file_check.stat.exists

    - name: Ensure the line is present in .bashrc
      lineinfile:
        path: /home/${VM_OS_ADMIN}/.bashrc  # Replace with the appropriate user home path
        line: 'source ${v_dest}'  # The line to add
        create: yes  # Create the file if it doesn't exist
        state: present

    - name: Update SCRIPT_DIR variable value in ${v_filename}
      replace:
        path: ${v_dest}
        regexp: '^SCRIPT_DIR=.*$'
        replace: 'SCRIPT_DIR=/home/${VM_OS_ADMIN}/script'
EOF

  sh -xc "ansible-playbook ${sc_tmp}.yaml"
else
  f_use
fi
