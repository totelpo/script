#!/bin/bash
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
# totel 2020
  echo "
 DESC: delete vm and files
USAGE: 
$sc_name1 PATTERN               DELETE_DIR EXECUTE
$sc_name1 ' c7-20.*-my80-gr '   y          n
$sc_name1 ' el9-090 '           y          n

virsh list --all
" | sed "s|$HOME|~|g"

exit
}

p_pattern="$1"         ; p_pattern=${p_pattern:=rac22} 
p_delete_dir="$2" ; p_delete_dir=${p_delete_dir:=n}
p_execute="$3"    ; p_execute=${p_execute:=n}

v_temp_script=$sc_tmp-script.sh
v_temp_vm_status=$sc_tmp-vm-status.sh

echo '
df -hT / > /tmp/df1.txt
echo
' > $v_temp_script

if [ $# -eq 3 ]; then
	virsh list --all | grep " $p_pattern " > $sc_tmp-to-delete.list
	if [ $? -gt 0 ]; then
		echo -e "\n[INFO] No VM name match with pattern '$p_pattern'. Check with :\nvirsh list --all | grep 'test'\n"
		exit
	fi
	for v_vm_name in `cat $sc_tmp-to-delete.list | awk '{ print $2 }'`; do
		virsh domblklist $v_vm_name --details > $v_temp_vm_status 
		if [ $? -gt 0 ]; then
			echo "[INFO] VM $v_vm_name NOT found." 
			exit
		fi
		v_domblklist="`cat $v_temp_vm_status | sed '1,2d' | grep 'file   disk'`"
		v_xml_bkp=/vm/kvm/$v_vm_name.xml
		set -e   # enable  script exit-on-error and return an exit status you can check with $?
		(
		echo
		printf '#%.0s' {1..55}
		echo -e "\nset -e"
		echo "virsh dumpxml $v_vm_name > $v_xml_bkp"
		v_files=$(echo "$v_domblklist" | awk '{ print $4 }')
		v_dirs="$(echo "$v_files"      | awk -F'/' '$NF = ""; {print $0}' OFS='/' | sort -u)"
		#echo -e "$v_files\n"
		echo '
virsh list --all | grep " '$v_vm_name' " | grep running && echo "virsh destroy  '$v_vm_name'" | sh -x
virsh list --all | grep " '$v_vm_name' "                && echo "virsh undefine '$v_vm_name'" | sh -x
		'
		v_cmd_rmdir=`echo "rm -rfv "$v_dirs`
		if [ "$p_delete_dir" = "y" ]; then
			echo "echo \"$v_cmd_rmdir\" | sh -x"
		else
			echo 'echo -e "## Directory not deleted. Manually delete by : \n\t '$v_cmd_rmdir' \n"'
			echo 'echo -e "## OR restore it by : \n\t virsh define '$v_xml_bkp' \n"' 
		fi
		) >> $v_temp_script
	done
	echo "echo; mv -v $v_temp_script $v_temp_script.done; echo '## Before '; cat /tmp/df1.txt ; echo '## After '; df -hT /; " >> $v_temp_script
else
	f_use
fi

v_cmd="bash $v_temp_script"
if [ "$p_execute" = y ]; then
        echo -e "\n### START `date +%F_%H-%M-%S` ### $v_cmd\n"
        $v_cmd
        echo -e "\n### END `date +%F_%H-%M-%S`### $v_cmd\n"
else
        echo -e "$v_cmd\n"
fi

