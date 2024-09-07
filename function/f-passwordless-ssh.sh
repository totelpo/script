
f-passwordless-ssh(){
f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3"
if [ $# -eq 3 ]; then
        fi_template=$1
        fi_vm_name="$2"
        fi_os_user="$3"  ; fi_os_user=${fi_os_user:=root}
        set -e
        f-get-kvm-ip $fi_vm_name # return r_ip
        echo; sh -xc "ssh-keygen -f ${HOME}/.ssh/known_hosts -R $r_ip"
        echo
        if [ "$fi_template" = "el5" ]; then
                sh -xc "ssh-copy-id -i ${HOME}/.ssh/id_rsa_kvm -o HostKeyAlgorithms=+ssh-rsa $fi_os_user@$r_ip"
        else
                sh -xc "ssh-copy-id -i ${HOME}/.ssh/id_rsa_kvm $fi_os_user@$r_ip"
        fi
        echo -e "\n# Test passwordless SSH :"
        sh -xc "ssh -i ${HOME}/.ssh/id_rsa_kvm $fi_os_user@$r_ip id"
else
	cat << EOF
# CALL first :
#vm-arp-clear-unreachable-ip.sh
#f-ansible-hosts-kvm
# USAGE : 
${FUNCNAME[0]} OS  VM_NAME OS_USER
${FUNCNAME[0]} el7 c7-070  root
EOF
fi
}

