f-ansible-template(){
if [ $# -eq 2 ]; then
	echo -e "\n[EXECUTING] ${FUNCNAME[0]} $@"
	i_os=$1
	i_ansible_host=$2
	ansible-wrapper.sh ${SCRIPT_DIR}/ansible/yaml/template-${i_os}.yaml $i_ansible_host
else
	echo -e "\n[USAGE] 
${FUNCNAME[0]} OS  ANSIBLE_HOST
${FUNCNAME[0]} el7 c7-070 "
fi
}
