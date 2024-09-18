#!/bin/bash
# DESC: Clone KVM vm 
# totel 20240816 v2.0 Change input from Positional Parameters to Environment Variable Assignment (Inline Export)

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
  echo "
# USAGE: 
        $sc_name1  OS   VM_ORIG   VM_CLONE    CLONE_IP        STAGE
        $sc_name1  el9  el9-090   el9-091     192.168.122.91  clone
CHECK=n $sc_name1  el9  el9-090   el9-091     192.168.122.91  ip
CHECK=n $sc_name1  el9  el9-090   el9-091     192.168.122.91  hostname

STAGE : clone|ip|hostname|all
" | sed "s|$HOME|~|g"

exit
}

s=~/t/$sc_name2.s
t=~/t/$sc_name2.t
l=~/t/$sc_name2.l

OS="$1"
VM_SOURCE="$2"
VM_CLONE="$3"
IP_CLONE="$4"
STAGE=$5
CHECK=${CHECK:=y}

if [ $# -eq 5 ]; then
  f-marker $sc_name1 $p_all_input_parameters
  if [ "${VM_SOURCE}" = "${VM_CLONE}" ]; then
    echo -e "\nVM_SOURCE(${VM_SOURCE}) must NOT be same with p_clone_vm(${VM_CLONE})\n"
    exit
  fi

  (virsh list --all | grep " ${VM_SOURCE} " | grep running) > /dev/null  && virsh destroy ${VM_SOURCE}; 

  set -e   # enable  script exit-on-error and return an exit status you can check with $?
 
  v_source_files=$(virsh domblklist ${VM_SOURCE} | grep ${VM_SOURCE} | awk '{ print "--file "$2 }' )
  v_clone_files=$(echo "${v_source_files}" | sed "s/${VM_SOURCE}/${VM_CLONE}/g" )
# echo -e "$v_source_files\n"
# echo -e "$v_clone_files\n"

  v_clone_dirs=$(echo "$v_clone_files" | awk '{print $2}' | grep 'root.img' | sort -u | while read i; do dirname $i; done | sort | uniq )
  #  v_clone_dirs1=`echo "$v_clone_files" | awk '{print $2}' | grep "${VM_CLONE}.img" | sort -u | head -1 | while read i; do dirname $i; done`

  if [ "${CHECK}" = "y" ]; then 
    set -e
    VM=${VM_CLONE} check-if-similar-vm-exists-based-on-name.sh
    IP=${IP_CLONE} check-if-similar-vm-exists-based-on-ip.sh
    IP=${IP_CLONE} check-if-ip-in-used.sh
    IP=${IP_CLONE} check-if-kvm-ip-is-valid.sh 

   for i_dir in ${v_clone_dirs}; do
      DIR_NAME=${i_dir} check-if-dir-is-empty-or-not-exists.sh
    done
    unset i_dir
  fi
    set +e

    cat << EOF > $sc_tmp.sh
mkdir -p  $v_clone_dirs

virt-clone \\
  --connect qemu:///system \\
  --original ${VM_SOURCE} \\
  --check disk_size=off \\
  --name ${VM_CLONE} \\
  $v_clone_files
EOF

cat << EOF > $sc_tmp.sh.clone

EXEC=y f-exec-temp-script $sc_tmp.sh

f-marker "Start VM"
bash -xc "virsh start ${VM_CLONE}"
  
f-marker "VM status"
vm-list.sh | egrep "${VM_CLONE}|^ Id"
  
EOF

set -e
STAGE=${STAGE:="all"}
if   [ "${STAGE}" = "all" -o "${STAGE}" = "clone" ]; then
  rm -fv $sc_tmp-stage-*.completed
  EXEC=y f-exec-temp-script $sc_tmp.sh.clone
  VM=${VM_CLONE} WAIT_MINUTE=2 wait-kvm-ip.sh
  f-marker "VM status"
  vm-list.sh "${VM_CLONE}"
  f-marker "VM cloning competed"
  bash -xc "touch $sc_tmp-stage-clone.completed"
  echo
elif [ "${STAGE}" = "all" -o "${STAGE}" = "ip" ]; then
  if [ ! -f $sc_tmp-stage-clone.completed ]; then
    echo -e "\nVM was not yet executed as indicated by missing file $sc_tmp-stage-clone.completed\n"
  fi
  OS=${OS} VM=${VM_CLONE} NEW_IP=${IP_CLONE} vm-change-ip.sh
  bash -xc "touch $sc_tmp-stage-ip.completed"
elif [ "${STAGE}" = "all" -o "${STAGE}" = "hostname" ]; then
  echo f_change_hostname_ip
  bash -xc "touch $sc_tmp-stage-hostname.completed"
fi

else
  f_use
fi
