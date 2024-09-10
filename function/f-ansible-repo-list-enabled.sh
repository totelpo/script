f-ansible-repo-list-enabled(){
	echo -e "\n[EXECUTING] ${FUNCNAME[0]} $@"
	i_ansible_host=$1
	ANSIBLE_COMMAND_WARNINGS=false ansible $i_ansible_host -a 'yum repolist enabled'
}
