#!/bin/bash
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
# DESC: totel 2020
# USAGE: 
	echo "
USAGE :
EXEC=y VM_OLD=el9-090 VM_NEW=el9-091 $sc_name1
" | sed "s|$HOME|~|g"
	exit 1
}

if [ ! -z "${VM_OLD}" -a ! -z "${VM_NEW}" ]; then # if required variables are not empty
  f-marker $sc_name1 $@
else
  echo "
FAILED: Empty variables found.
VM_OLD=${VM_OLD}
VM_NEW=${VM_NEW}
"
	f_use
fi

set -e
virsh dumpxml ${VM_OLD} > ${sc_tmp}.xml

v_img1=`virsh domblklist ${VM_OLD} --details | grep 'file' | head -1 | awk '{ print $NF }'`
	#v_img1=`cat ${sc_tmp}.root.img | awk -F"'" '{ print $2 }'`
v_old_vm_dir=`dirname $v_img1`
v_new_vm_dir=`echo $v_old_vm_dir | sed "s/${VM_OLD}/${VM_NEW}/g"`
set +e

# Check old and new value
if [ "${VM_OLD}" = "${VM_NEW}" ]; then
  echo -e "\nOld name(${VM_OLD}) and New name(${VM_OLD}) are the same.\n"
  exit 1
fi
f-check-if-dir-exists ${v_new_vm_dir}
f-check-if-vm-exists  ${VM_NEW}

cat << EOF > ${sc_tmp}.sh
(
if (virsh list --all | grep ${VM_OLD} | grep running); then   # destroy if VM is running
  virsh destroy ${VM_OLD}
fi
set -e
virsh undefine ${VM_OLD}
mv -nv $v_old_vm_dir $v_new_vm_dir
sed -i "s|${VM_OLD}|${VM_NEW}|g" ${sc_tmp}.xml
grep ${VM_NEW}  ${sc_tmp}.xml
virsh define ${sc_tmp}.xml
virsh start ${VM_NEW}
ls -lh ${sc_tmp}.xml
)
EOF
if [ "${EXEC}" = "y" ]; then
  bash -x ${sc_tmp}.sh
else
  echo -e "\nManually execute :\nbash -x ${sc_tmp}.sh\n"
fi
