#!/bin/bash
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
  echo "
USAGE: 
$sc_name1 VM
$sc_name1 rac23
" | sed "s|$HOME|~|g"

exit
}

set -e
if [ $# -eq 1 ]; then
  v_vm=$1

f-exec-command "virsh dominfo   $v_vm | egrep -i 'memory|cpu'"
f-exec-command "virsh dumpxml   $v_vm | egrep -i 'memory|cpu'"
f-exec-command "virsh vcpucount $v_vm"
f-exec-command "virsh domiflist $v_vm"
f-exec-command "virsh domifaddr $v_vm"
f-exec-command "virsh domif-getlink $v_vm `virsh domiflist $v_vm | grep vnet | awk '{ print $1 }'`"
f-exec-command "virsh domblklist $v_vm --details"
f-exec-command "du -shc /vm/kvm/$v_vm"
else
  f_use
fi
