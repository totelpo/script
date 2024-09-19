f-ssh-ensure-connectivity(){
<<INFO
For :
1) New VM
2) Renamed VM
3) Change of IP
4) Change of Hostname
5) Cloned VM
INFO
f-message EXECUTING "${FUNCNAME[0]} $1"
i_ip=$1
  f-exec-command "ssh-keygen -f /home/totel/.ssh/known_hosts -R $i_ip ### To avoid 'WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED'"
  f-ip-wait-to-be-reachable $i_ip
  f-exec-command "ssh -i /home/totel/.ssh/id_rsa_kvm -o StrictHostKeyChecking=no -o PasswordAuthentication=no $v_ssh_extra root@$i_ip id ### StrictHostKeyChecking=no : To avoid host key prompt during login"
}

