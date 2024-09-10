
f-passwordless-ssh(){
f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3"
if [ $# -eq 2 ]; then
        fi_os=$1
        fi_ip="$2"
        set -e
        echo; sh -xc "ssh-keygen -f ${HOME}/.ssh/known_hosts -R ${fi_ip}"
        echo
        if [ "${fi_os}" = "el5" ]; then
                sh -xc "ssh-copy-id -i ${HOME}/.ssh/id_rsa_kvm -o HostKeyAlgorithms=+ssh-rsa ${fi_ip}"
        else
                sh -xc "ssh-copy-id -i ${HOME}/.ssh/id_rsa_kvm ${fi_ip}"
        fi
        echo -e "\n# Test passwordless SSH :"
        sh -xc "ssh -i ${HOME}/.ssh/id_rsa_kvm ${fi_ip} id"
else
	cat << EOF
# CALL first :
#vm-arp-clear-unreachable-ip.sh
#f-ansible-hosts-kvm
# USAGE : 
${FUNCNAME[0]} OS  IP
${FUNCNAME[0]} el9 192.168.122.90
EOF
fi
}

