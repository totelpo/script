#!/bin/bash
# totel 20240816 v2.0 Change input from Positional Parameters to Environment Variable Assignment (Inline Export)

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
  echo "
totel 2020
 DESC: clone rac vm 
USAGE: 
$sc_name1  OS   VM_ORIG   VM_CLONE    CLONE_IP    
$sc_name1  el8  el8-080   el8-081     192.168.122.81
$sc_name1  el9  el9-090   el9-091     192.168.122.91
" | sed "s|$HOME|~|g"

exit
}

s=~/t/$sc_name2.s
t=~/t/$sc_name2.t
l=~/t/$sc_name2.l

OS="$1";   OS=${OS:=el7} # default value
VM_SOURCE="$2"; VM_SOURCE=${VM_SOURCE:=centos7t} # default value
VM_CLONE="$3" ; VM_CLONE=${VM_CLONE:=c7n71}           # default value
IP_CLONE="$4" ; IP_CLONE=${IP_CLONE:=192.168.122.71}           # default value

if [ $# -eq 4 ]; then
  f-marker $sc_name1 $p_all_input_parameters
  if [ "${VM_SOURCE}" = "${VM_CLONE}" ]; then
    echo -e "\nVM_SOURCE(${VM_SOURCE}) must NOT be same with p_clone_vm(${VM_CLONE})\n"
    exit
  fi

  vm-list.sh "${VM_SOURCE}" | grep running && virsh destroy  ${VM_SOURCE}; 

  set -e   # enable  script exit-on-error and return an exit status you can check with $?
 
  virsh domblklist ${VM_SOURCE} | grep '.img' #| sed "s/${VM_SOURCE}/${VM_CLONE}/g" | awk '{ print "--file "$2 }'
 
  v_clone_files=$( virsh domblklist ${VM_SOURCE} | grep ${VM_SOURCE} | awk '{ print "--file "$2 }' | sed "s/${VM_SOURCE}/${VM_CLONE}/g" )
  v_source_files=$(virsh domblklist ${VM_SOURCE} | grep ${VM_SOURCE} | awk '{ print "--file "$2 }' )
  echo -e "$v_clone_files\n"
  echo -e "$v_source_files\n"

  v_clone_dirs=$(echo "$v_clone_files" | awk '{print $2}' | grep 'root.img' | sort -u | while read i; do dirname $i; done | sort | uniq )
  #  v_clone_dirs1=`echo "$v_clone_files" | awk '{print $2}' | grep "${VM_CLONE}.img" | sort -u | head -1 | while read i; do dirname $i; done`

  CHECK=${CHECK:=y}
  if [ "${CHECK}" = "y" ]; then 
    set -e
    f-check-if-similar-vm-id-exist  ${VM_CLONE}
    VM=${VM_CLONE} IP=${IP_CLONE} check-if-similar-vm-exists-based-on-ip.sh
    IP=${IP_CLONE} check-if-ip-in-used.sh
    IP=${IP_CLONE} check-if-kvm-ip-is-valid.sh 

   for i_dir in ${v_clone_dirs}; do
      DIR_NAME=${i_dir} check-if-dir-is-empty-or-not-exists.sh
    done
    unset i_dir
  fi
    set +e

    cat << EOF > $sc_tmp.sh
virt-clone \\
  --connect qemu:///system \\
  --original ${VM_SOURCE} \\
  --check disk_size=off \\
  --name ${VM_CLONE} \\
  $v_clone_files
EOF

cat << EOF > $sc_tmp.sh.1
bash -xc "mkdir -p  $v_clone_dirs"

EXEC=y f-exec-temp-script $sc_tmp.sh

bash -xc "virsh start ${VM_CLONE}"
  
vm-list.sh | egrep "${VM_CLONE}|^ Id"
  
EOF

# EXEC=y f-exec-temp-script $sc_tmp.sh.1

VM=${VM_CLONE} WAIT_MINUTE=2 f-ip-wait-kvm-to-acquire ; # returns $r_ip
 
vm-list.sh | egrep " ${VM_CLONE} |^ Id"

OS=${OS} VM=${VM_CLONE} NEW_IP=${IP_CLONE} vm-change-ip.sh

  #f_change_hostname_ip
else
  f_use
fi
