f-ansible-hosts-old(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3 $4 $5"
	v_conf=/etc/ansible/hosts
	echo "[all]" > $v_conf
	for i in {2..254}; do
		i_pad=`printf "%03d" $i`
		echo "s$i_pad ansible_host=192.168.122.$i ansible_port=22 ansible_user=${VM_OS_ADMIN} ansible_become_user=root ansible_ssh_private_key_file=${HOME}/.ssh/id_rsa_kvm ansible_ssh_common_args='-o StrictHostKeyChecking=no'"

	done | column -t -o' ' >> $v_conf
  cat << EOF >> $v_conf
[pxc]
s171
s172
s173
EOF
	cp -v $v_conf $v_conf.old
}


