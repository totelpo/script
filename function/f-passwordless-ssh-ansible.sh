
f-passwordless-ssh-ansible(){
f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3"
if [ $# -eq 3 ]; then
        fi_template=$1
        fi_ansible_host="$2"
        fi_os_user="$3"  ; fi_os_user=${fi_os_user:=root}
        set -e
        f-get-ansible-ip $fi_ansible_host exit1 # return r_ip
        echo; ssh-keygen -f "/home/totel/.ssh/known_hosts" -R "$r_ip"
        echo
        if [ "$fi_template" = "el5" ]; then
                ssh-copy-id -i /home/totel/.ssh/id_rsa_kvm -o HostKeyAlgorithms=+ssh-rsa $fi_os_user@$r_ip
        else
                ssh-copy-id -i /home/totel/.ssh/id_rsa_kvm $fi_os_user@$r_ip
        fi
        echo -e "\n# Try connecting by :\nssh -i /home/totel/.ssh/id_rsa_kvm $fi_os_user@$r_ip\n"
else
	cat << EOF
#f-ansible-hosts-kvm
# USAGE : 
${FUNCNAME[0]} OS  ANSIBLE_HOST OS_USER
${FUNCNAME[0]} el7 l-c7         root
EOF
fi
}

