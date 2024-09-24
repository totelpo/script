#!/bin/bash
# DESC: Rename KVM guest 
# totel 20240925 v1.0

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
  echo "
# USAGE: 
$sc_name1  VM_OLD   VM_NEW    NEW_IP        
$sc_name1  el9-091  el9-092   192.168.122.92
$sc_name1  el9-091  el9-092   192.168.122.92
$sc_name1  el9-091  el9-092   192.168.122.92

STAGE : rename|ip|all
" | sed "s|$HOME|~|g"

exit
}

VM_OLD="$1"
VM_NEW="$2"
NEW_IP="$3"

if [ $# -eq 3 ]; then
  f-marker $sc_name1 $p_all_input_parameters
  if [ "${VM_OLD}" = "${VM_NEW}" ]; then
    echo -e "\nVM_OLD(${VM_OLD}) must NOT be same with VM_NEW(${VM_NEW})\n"
    exit
  fi

  VM=${VM_OLD} f-get-kvm-ip  ; v_old_ip=${r_ip}

  set -e   # enable  script exit-on-error and return an exit status you can check with $?
 
  VM=${VM_NEW} check-if-similar-vm-exists-based-on-name.sh
  if [ ! -z "${NEW_IP}" -a ! "${v_old_ip}" = "${NEW_IP}" ]; then 
    IP=${NEW_IP} check-if-similar-vm-exists-based-on-ip.sh
    IP=${NEW_IP} check-if-ip-in-used.sh
    IP=${NEW_IP} check-if-kvm-ip-is-valid.sh 

  fi

  set -e
  v_img1=$(virsh domblklist ${VM_OLD} --details | grep 'file' | head -1 | awk '{ print $NF }')
  v_old_vm_dir=$(dirname $v_img1)
  virsh dumpxml ${VM_OLD} > ${sc_tmp}.xml
  v_new_vm_dir=$(echo ${v_old_vm_dir} | sed "s/${VM_OLD}/${VM_NEW}/g")

  DIR_NAME=${v_new_vm_dir} check-if-dir-does-not-exists.sh
  
  cat << EOF > $sc_tmp.sh
set -e
f-marker "Ensure the old VM is stopped"
(virsh list --all | grep " ${VM_OLD} " | grep running) > /dev/null  && virsh destroy ${VM_OLD}

f-marker "Undefine the old VM"
bash -xc "virsh undefine ${VM_OLD}"

f-marker "Rename folder"
bash -xc "mv -nv $v_old_vm_dir $v_new_vm_dir"

f-marker "Update XML definition file ${sc_tmp}.xml"
sed -i "s|${VM_OLD}|${VM_NEW}|g" ${sc_tmp}.xml

f-marker "Define the new VM"
bash -xc "virsh define ${sc_tmp}.xml"

ls -lh ${sc_tmp}.xml

f-marker "Start VM"
bash -xc "virsh start ${VM_NEW}"
  
VM=${VM_NEW} WAIT_MINUTE=2 wait-kvm-ip.sh
EOF

set -e

rm -f $sc_tmp-stage-*.completed
EXEC=y f-exec-temp-script $sc_tmp.sh
f-marker "VM status"
vm-list.sh "${VM_NEW}"
f-marker "VM name change competed"
bash -xc "touch $sc_tmp-stage-name-change.completed"
VM=${VM_NEW}  an-change-hostname.sh
bash -xc "touch $sc_tmp-stage-hostname.completed"
echo
vm-list.sh "${VM_NEW}"

if [ ! -z "${NEW_IP}" -a ! "${v_old_ip}" = "${NEW_IP}" ]; then 
  if [ ! -f $sc_tmp-stage-rename.completed ]; then
    echo -e "\nVM rename was not yet executed as indicated by missing file $sc_tmp-stage-rename.completed\n"
  fi
  VM=${VM_NEW} NEW_IP=${NEW_IP} an-change-ip.sh
  echo
  bash -xc "touch $sc_tmp-stage-ip.completed"
fi


else
  f_use
fi
