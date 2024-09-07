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

f-cmd-verbose "virsh dominfo   $v_vm | egrep -i 'memory|cpu'"
f-cmd-verbose "virsh dumpxml   $v_vm | egrep -i 'memory|cpu'"
f-cmd-verbose "virsh vcpucount $v_vm"
f-cmd-verbose "virsh domiflist $v_vm"
f-cmd-verbose "virsh domifaddr $v_vm"
f-cmd-verbose "virsh domif-getlink $v_vm `virsh domiflist $v_vm | grep vnet | awk '{ print $1 }'`"
f-cmd-verbose "virsh domblklist $v_vm --details"
f-cmd-verbose "du -shc /vm/kvm/$v_vm"
else
  f_use
fi
