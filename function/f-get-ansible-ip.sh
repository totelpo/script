f-get-ansible-ip(){
	i_ansible_host=$1
	i_exit=$2
	v_conf=/etc/ansible/hosts
	r_ip=`grep "^$i_ansible_host " $v_conf | awk '{ print $2 }' | cut -d= -f2`
	if [ "$r_ip" = "" ]; then
		echo -e "\nNo entry for ansible host '$i_ansible_host' on '$v_conf'\n"
		if [ "$i_exit" = "exit1" ]; then
			exit 1
		fi
	fi
}
