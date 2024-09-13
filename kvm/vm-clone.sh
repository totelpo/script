#!/bin/bash
sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

f_use() {
  echo "
totel 2020
 DESC: clone rac vm 
USAGE: 
$sc_name1  OS   VM_ORIG   VM_CLONE    CLONE_IP    
$sc_name1  el8  el8-080   el8-081     192.168.122.81
$sc_name1  el9  el9-090   el9-091     192.168.122.91
" | sed "s|$HOME|~|g"

exit
}

s=~/t/$sc_name2.s
t=~/t/$sc_name2.t
l=~/t/$sc_name2.l

p_os="$1";   p_os=${p_os:=el7} # default value
p_source_vm="$2";   p_source_vm=${p_source_vm:=centos7t} # default value
p_clone_vm="$3" ; p_clone_vm=${p_clone_vm:=c7n71}           # default value
p_clone_ip="$4" ; p_clone_ip=${p_clone_ip:=192.168.122.71}           # default value

if [ $# -eq 4 ]; then
  f-marker $sc_name1 $p_all_input_parameters
  if [ "${p_source_vm}" = "${p_clone_vm}" ]; then
    echo -e "\np_source_vm(${p_source_vm}) must NOT be same with p_clone_vm(${p_clone_vm})\n"
    exit
  fi

  f_change_hostname_ip(){
    f-marker ${FUNCNAME[0]}
    v_cmd="vm-change-hostname-ip-p1.sh $p_os ${p_clone_vm} ${p_clone_ip}"
    echo -e "\nexecuting :\n ### $v_cmd ###"
    eval "$v_cmd"
  }

# f-check-if-similar-vm-id-exist  ${p_clone_vm}
# f-check-if-similar-vm-exists-based-on-ip ${p_clone_ip}
# f-check-if-ip-in-used           ${p_clone_ip}
# f-check-if-kvm-ip-is-valid      ${p_clone_ip}
  f_clone(){
  
    vm-list.sh "${p_source_vm}" | grep running && virsh destroy  ${p_source_vm}; 
  
    set -e   # enable  script exit-on-error and return an exit status you can check with $?
  
    virsh domblklist ${p_source_vm} | grep '.img' #| sed "s/${p_source_vm}/${p_clone_vm}/g" | awk '{ print "--file "$2 }'
  
    v_clone_files=$( virsh domblklist ${p_source_vm} | grep ${p_source_vm} | awk '{ print "--file "$2 }' | sed "s/${p_source_vm}/${p_clone_vm}/g" )
    v_source_files=$(virsh domblklist ${p_source_vm} | grep ${p_source_vm} | awk '{ print "--file "$2 }' )
    echo -e "$v_clone_files\n"
    echo -e "$v_source_files\n"
  
    v_clone_dir=$(echo "$v_clone_files" | awk '{print $2}' | grep 'root.img' | sort -u | while read i; do dirname $i; done | sort | uniq )
    #  v_clone_dir1=`echo "$v_clone_files" | awk '{print $2}' | grep "${p_clone_vm}.img" | sort -u | head -1 | while read i; do dirname $i; done`
  
    pwd
    bash -xc "mkdir -p  $v_clone_dir"
    
    set +e
    for i_dir in ${v_clone_dir}; do
      f-check-if-dir-is-empty ${i_dir}
    done
    unset i_dir

    cat << EOF > $sc_tmp.sh
virt-clone \\
  --connect qemu:///system \\
  --original ${p_source_vm} \\
  --check disk_size=off \\
  --name ${p_clone_vm} \\
  $v_clone_files
EOF
    bash -x $sc_tmp.sh
  
    virsh start ${p_clone_vm}
    
  
    vm-list.sh | egrep "${p_clone_vm}|^ Id"
  }
  f_clone
  f-ip-wait-kvm-to-acquire ${p_clone_vm} 120 ; v_ip=$r_ip
  #f_change_hostname_ip
  #f-ip-clear-arp $v_ip
  #f-ssh-extra-arg-conf $p_os

  vm-list.sh | egrep " ${p_clone_vm} |^ Id"
  
#f-cmd-verbose "ssh-keygen -f /home/totel/.ssh/known_hosts -R ${p_clone_ip} # Cleanup known hosts for new vm"
#f-cmd-verbose "ssh -o StrictHostKeyChecking=no $v_ssh_extra ${p_clone_ip} 'hostname' > /dev/null  # this will prevent any prompt for succeding ssh connections" 
#f-cmd-verbose "ssh $v_ssh_extra root@${p_clone_ip} 'hostname' # test " 
else
  f_use
fi
