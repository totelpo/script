f-ansible-hosts-kvm(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3 $4 $5"
	vm-list.sh running > /dev/null
	v_conf=/etc/ansible/hosts
	echo "[all]" > $v_conf
	cat ${TMPDIR}/vm-list.out | grep 'running' | tr -s ' ' | awk -F'|' '{ if($2 != " ") print $0 }' | sed 's/|//g' | awk -v a_vm_os_admin=${VM_OS_ADMIN} -v a_home=${HOME} '{ print $2, "ansible_host="$4, "ansible_port=22 ansible_user="a_vm_os_admin" ansible_become_user=root ansible_ssh_private_key_file="a_home"/.ssh/id_rsa_kvm ansible_ssh_common_args=\"-o StrictHostKeyChecking=no\"" }' | column -t -o' ' >> $v_conf

	cp -v $v_conf $v_conf.kvm
	sh -xc "ansible -m ping all"
}


