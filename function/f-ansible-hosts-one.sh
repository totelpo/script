f-ansible-hosts-one(){
	f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3 $4 $5"
	ANSIBLE_HOST_FILE_ONE=${TMPDIR}/ansible-hosts-one
  if [ ! -z ${IP} ]; then
	  echo "[one]" > ${ANSIBLE_HOST_FILE_ONE}
    v_ip_end=$(echo $IP | cut -d'.' -f 4)
		i_pad=`printf "%03d" $v_ip_end`
		echo "s$i_pad ansible_host=${IP} ansible_port=22 ansible_user=${VM_OS_ADMIN} ansible_become_user=root ansible_ssh_private_key_file=${HOME}/.ssh/id_rsa_kvm ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ${ANSIBLE_HOST_FILE_ONE}
	  ls -lh ${ANSIBLE_HOST_FILE_ONE}
  else
    echo "
USAGE :
IP=192.168.122.x  ${FUNCNAME[0]} 
IP=192.168.122.90 ${FUNCNAME[0]} 
"
  fi
}


