#!/bin/bash
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
	f-marker ${FUNCNAME[0]}
# DESC: totel 2020
# USAGE: 
	echo "
EXEC=y $sc_name1 VM_OLD  VM_NEW
EXEC=y $sc_name1 c7-0171 c7-171
" | sed "s|$HOME|~|g"
	exit
}

if [ $# -eq 2 ]; then
	f-marker $sc_name1 $@
else
	f_use
fi

p_old_vm="$1"
p_new_vm="$2"

set -e
virsh dumpxml ${p_old_vm} > ${sc_tmp}.xml

v_img1=`virsh domblklist ${p_old_vm} --details | grep 'file' | head -1 | awk '{ print $NF }'`
	#v_img1=`cat ${sc_tmp}.root.img | awk -F"'" '{ print $2 }'`
v_old_vm_dir=`dirname $v_img1`
v_new_vm_dir=`echo $v_old_vm_dir | sed "s/${p_old_vm}/$p_new_vm/g"`
set +e

# Check old and new value
if [ "${p_old_vm}" = "${p_new_vm}" ]; then
  echo -e "\nOld name(${p_old_vm}) and New name(${p_old_vm}) are the same.\n"
  exit 1
fi
f-check-if-dir-exists ${v_new_vm_dir}
f-check-if-vm-exists  ${p_new_vm}

cat << EOF > ${sc_tmp}.sh
(
if (virsh list --all | grep ${p_old_vm} | grep running); then   # destroy if VM is running
  virsh destroy ${p_old_vm}
fi
set -e
virsh undefine ${p_old_vm}
mv -nv $v_old_vm_dir $v_new_vm_dir
sed -i "s|${p_old_vm}|$p_new_vm|g" ${sc_tmp}.xml
grep $p_new_vm  ${sc_tmp}.xml
virsh define ${sc_tmp}.xml
virsh start $p_new_vm
ls -lh ${sc_tmp}.xml
)
EOF
if [ "${EXEC}" = "y" ]; then
  bash -x /home/totel/t/vm-rename.sh
else
  echo -e "\nbash -x /home/totel/t/vm-rename.sh\n"
fi
