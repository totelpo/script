#!/bin/bash
# DESC: create virtual machine template with any hostname and IP
# totel 20201127
# totel 20240903 added to github repo
#                Tested on el9 el8
set -e   # exit script when error occurs
sc_name=$0

source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh


f_use() {
  echo "
USAGE: 
EXEC=n OS=el7 VM=el7-070 IP=192.168.122.70 DISK_GB=20 $sc_name1 
EXEC=n OS=el8 VM=el8-080 IP=192.168.122.80 DISK_GB=20 $sc_name1 
EXEC=n OS=el9 VM=el9-090 IP=192.168.122.90 DISK_GB=20 $sc_name1  # DISK_GB=80 for Minikube

# VM el5|el6|el7|el8
# ls ${SCRIPT_DIR}/kvm/kvm-el.sh # Edit for ISO location

" | sed "s|$HOME|~|g"

exit
}

v_log=${TMPDIR}/${sc_name2}.log
v_sh=${sc_tmp}-${VM}.sh
v_yaml=${TMPDIR}/template-${OS}.yaml
v_hosts_file=${TMPDIR}/template-ansible-hosts

f-ip-to-server-id  # returns r_ansible_host


<<COMMENT
# http://linux.dell.com/files/whitepapers/KVM_Virtualization_in_RHEL_7_Made_Easy.pdf
# /hd/d/os/centos/KVM_Virtualization_in_RHEL_7_Made_Easy.pdf

cd /var/www/html/
ln -s /iso/c5d1
ln -s /iso/c5d2
ln -sf /hd/d/os/kvm/ks-centos5.cfg
ln -sf /hd/d/os/kvm/ks-centos7.cfg
ln -sf /hd/d/os/kvm/ks-rocky8.cfg
chmod 644 /hd/d/os/kvm/ks-centos5.cfg
chmod 644 /hd/d/os/kvm/ks-centos7.cfg
chmod 644 /hd/d/os/kvm/ks-rocky8.cfg
COMMENT

p_kickstart_dir=${SCRIPT_DIR}/kvm/kickstart
f-el-kickstart-update(){
  p_network_device=$1 ; p_network_device=${p_network_device:=eth0}
  sed -i "s|^network .*|network --device $p_network_device --bootproto static --noipv6 --ip ${IP} --netmask 255.255.255.0 --gateway 192.168.122.1 --nameserver 192.168.122.1,8.8.8.8 --hostname ${VM}.kvmpo.local|g" $p_kickstart_dir/$p_kickstart_file
}

DISK_GB="${DISK_GB:=20}" # default

if [ ! -z "${OS}" -a ! -z "${VM}" -a ! -z "${IP}" ]; then # if required variables are not empty
  MARKER_WIDTH=105 f-marker $sc_name1 OS=${OS} VM=${VM} IP=${IP}  # MARKER_WIDTH=105 for main script; MARKER_WIDTH=100(default) for minor script
  set -e; check-os-support.sh; set +e
else
  # Ensure required variables are defined
  echo "
FAILED: Empty variables found.
OS=${OS} | VM=${VM} | IP=${IP}
"
  f_use
fi

  v_dir=${KVM_DIR}/${VM}
  mkdir -p $v_dir
  set +e
  f_checks(){
    f-check-if-vm-exists       ${VM}
    f-check-if-kvm-ip-is-valid ${IP}
    f-check-if-ip-in-used      ${IP}
    f-check-if-similar-vm-exists-based-on-ip ${IP}
    f-check-if-dir-is-empty $v_dir
  }
# f_checks # move to kvm-el.sh

  v_img_root=$v_dir/root.img

f_passwordless_ssh(){
  f-marker ${FUNCNAME[0]}
  v_os_user="$1"  ; v_os_user=${v_os_user:=root}
  set -e
  f-get-kvm-ip ${VM} # return r_ip
  echo; ssh-keygen -f "/home/totel/.ssh/known_hosts" -R "$r_ip"
  echo
  v_ip=$r_ip
  if [ "${OS}" = "el5" ]; then
    ssh-copy-id -i /home/totel/.ssh/id_rsa_kvm -o HostKeyAlgorithms=+ssh-rsa $v_os_user@$v_ip
  else
    ssh-copy-id -i /home/totel/.ssh/id_rsa_kvm $v_os_user@$v_ip
  fi
  echo -e "\n# Try connecting by :\nssh -i /home/totel/.ssh/id_rsa_kvm $v_os_user@$v_ip\n"
}
f_template_sh(){
  f-marker ${FUNCNAME[0]}
  echo "cd ~/d/scripts/ansible/sh/" | sh -x
  l=$v_log.$sc_name1.${VM}
  OS_sh=$1
  v_cmd="vm-template-sh.sh ${IP} ${OS}_sh 2"
  echo -e "\n# Executing # $v_cmd\n"
  echo -e "\n# Log # ${v_log}\n"
  eval "$v_cmd" 2>&1 &> ${v_log}
  echo -e "\n# Executed # $v_cmd\n"
}
f_echo_ubuntu(){
  echo "
# set username/pass to ubuntu/abc123
  │ Choose software to install:                                             │
  │                      [*] OpenSSH server                                 │
# apt install iputils-ping

egrep '^PermitRootLogin|^PasswordAuthentication' /etc/ssh/sshd_config
systemctl restart sshd
/etc/init.d/ssh restart
"
}
######################
f_el5(){     
  f-marker ${FUNCNAME[0]}
  p_kickstart_file=el5.ks
  NETDEV=eth0 f-el-kickstart-update 
  virt-install \
    --network bridge:virbr0 \
    --name ${VM} \
    --ram=1024 \
    --vcpus=1 \
    --disk path=$v_dir/root.img,size=20 \
    --location=$1 \
    --graphics none \
    --os-variant=centos5.11 \
    --extra-args="ks=http://192.168.122.1/ks/$p_kickstart_file ip=192.168.122.5 netmask=255.255.255.0 gateway=192.168.122.1 console=tty0 console=ttyS0,115200"
}
######################
f_el6(){
  f-marker ${FUNCNAME[0]}
  p_kickstart_file=el6.ks
  NETDEV=eth0 f-el-kickstart-update
  virt-install \
    --network bridge:virbr0 \
    --name ${VM} \
    --ram=$((1024*1)) \
    --vcpus=1 \
    --disk path=$v_dir/root.img,size=20 \
    --location=$1 \
    --graphics none \
    --os-variant=centos6.10 \
    --extra-args="ks=http://192.168.122.1/ks/$p_kickstart_file ip=192.168.122.6 netmask=255.255.255.0 gateway=192.168.122.1 console=tty0 console=ttyS0,115200"
    #--extra-args="hostname=el6 ip=192.168.122.6 netmask=255.255.255.0 gateway=192.168.122.1 console=tty0 console=ttyS0,115200"
}

######################
f_u16(){
  f-marker ${FUNCNAME[0]}
  f_echo_ubuntu
  echo "sleep 9" | sh -x
  virt-install \
    --name ${VM} \
    --ram 1024 \
    --disk path=$v_dir/root.img,size=20,bus=virtio \
    --vcpus 1 \
    --os-variant ubuntu16.04 \
    --network bridge:virbr0,model=virtio \
    --graphics none \
    --location $1,kernel=install/vmlinuz,initrd=install/initrd.gz \
    --extra-args 'console=ttyS0,115200n8'
  echo "
ssh ubuntu@${IP}

# to enable virsh console access to ubuntu 16 guest.  
# https://www.cyberciti.biz/faq/how-to-enable-kvm-virsh-console-access-for-ubuntu-linux-vm/
systemctl enable serial-getty@ttyS0.service
systemctl start serial-getty@ttyS0.service

cp -nv /etc/network/interfaces /etc/network/interfaces.bkp

# vi /etc/network/interfaces
iface ens2 inet static
        address ${IP}
        netmask 255.255.255.0
        gateway 192.168.122.1
dns-nameservers 192.168.122.1 8.8.8.8

# /etc/init.d/networking restart
# apt install iputils-ping
"

  #  --console pty,target_type=serial \
}
######################
f_u20(){
  f-marker ${FUNCNAME[0]}
  f_echo_ubuntu
  echo "sleep 9" | sh -x
  virt-install \
    --name ${VM} \
    --ram 2048 \
    --disk path=$v_dir/root.img,size=20,bus=virtio \
    --vcpus 1 \
    --os-variant ubuntu20.04 \
    --network bridge:virbr0 \
    --graphics none \
    --console pty,target_type=serial \
    --location $1,kernel=casper/vmlinuz,initrd=casper/initrd \
    --extra-args 'console=ttyS0,115200n8'
}
######################

f_u22(){
  f-marker ${FUNCNAME[0]}
  f_echo_ubuntu
  echo "sleep 9" | sh -x
  virt-install \
    --name ${VM} \
    --ram 1024 \
    --disk path=$v_dir/root.img,size=20,bus=virtio \
    --vcpus 1 \
    --os-variant ubuntu22.04 \
    --network bridge:virbr0 \
    --graphics none \
    --console pty,target_type=serial \
    --location /iso/ubuntu/ubuntu-22.04-live-server-amd64.iso,kernel=casper/vmlinuz,initrd=casper/initrd \
    --extra-args 'console=ttyS0,115200n8'
}
######################
f_ubuntu_x(){
  cat << EOF > ${v_sh}.tmp
EXEC=y VM=${VM} f-kvm-${OS} 1
echo 'grep PermitRootLogin /etc/ssh/sshd_config  ### systemctl restart sshd '
vm-arp-clear-unreachable-ip.sh
f-passwordless-ssh ${OS} ${VM} root
f-ansible-hosts-kvm
#f-ansible-template            ${OS} ${VM}
#EXEC=y f-ansible-repo-mysql-yum-install  ${VM} ${OS}
#f-ansible-repo-list-enabled         ${VM} 
f-get-ansible-ip                    ${VM}   # return r_ip
vm-copy-scripts.sh                  \$r_ip
vm-change-hostname-ip-p1.sh   ${OS} ${VM} ${IP}
vm-arp-clear-unreachable-ip.sh
f-ansible-hosts-old
EOF
  if [ "${EXEC}" = y ]; then
    f-exec-temp-script ${v_sh}.tmp
  else
    echo -e "\nf-exec-temp-script ${v_sh}.tmp"
  fi
}
f_el_x(){
  if [ "${OS}" = "el7" -o "${OS}" = "el8" -o "${OS}" = "el9" ]; then
  cat << EOF > ${v_sh}.tmp
EXEC=y VM=${VM} OS=${OS} KS=${OS}.ks PROTO=static IP=${IP} DISK_GB=${DISK_GB} RAM_GB=2 CPU=2 kvm-el.sh 
EOF
  else
  cat << EOF > ${v_sh}.tmp
EXEC=y VM=${VM} KS=${OS}.ks PROTO=static IP=${IP} f-kvm-${OS} 1
EOF
  fi
  cp ${SCRIPT_DIR}/ansible/yaml/template-el-7-8-9.yaml ${v_yaml}
  sed -i "s|el-7-8-9|${OS}|g" ${v_yaml}
  cat << EOF >> ${v_sh}.tmp

(
set -e

VM=${VM} f-get-kvm-ip   # return r_ansible_host
YAML=${v_yaml} ANSIBLE_HOST=${r_ansible_host} ansible-wrapper.sh
IP=${IP} vm-os-admin-set-env.sh
IP=${IP} vm-copy-scripts.sh
# EXEC=y f-ansible-repo-percona-yum-install  ${r_ansible_host}            n
# EXEC=y f-ansible-repo-mysql-yum-install    ${r_ansible_host} ${OS} ''   n
# EXEC=y f-ansible-repo-mmariadb-yum-install ${r_ansible_host} ${OS} 11.2 n
echo "\nVM template ${VM} is now complete.\n"
)
EOF
  if [ "${EXEC}" = y ]; then
    f-exec-temp-script ${v_sh}.tmp
  else
    echo -e "\nf-exec-temp-script ${v_sh}.tmp"
  fi
}
######################

  if [ "${OS}" = "el5" ]; then
    ISO_FILE=${ISO_FILE:=/iso/centos/5/CentOS-5.11-x86_64-bin-DVD-1of2.iso}   # set default if empty
    f_el5 ${ISO_FILE}
    f-ssh-config-el5
    f_passwordless_ssh 
    f_template_sh el5-template.sh
  elif [ "${OS}" = "el6" ]; then
    ISO_FILE=${ISO_FILE:=/iso/centos/6/CentOS-6.10-x86_64-bin-DVD1.iso}   # set default if empty
    f_el6 ${ISO_FILE}
    f-ssh-config-el6
    f_passwordless_ssh
    f_template_sh el6-template.sh
  elif [ "${OS}" = "el7" ]; then
    f_el_x
  elif [ "${OS}" = "el8" ]; then
    f_el_x
  elif [ "${OS}" = "el9" ]; then
    f_el_x
  elif [ "${OS}" = "u16" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ubuntu/ubuntu-16.04.7-server-amd64.iso}   # set default if empty
    f_u16 ${ISO_FILE}
    f_passwordless_ssh ubuntu
    vm-change-hostname-ip-p1.sh  u16 u16-016 ${IP}
  elif [ "${OS}" = "u20" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ubuntu/ubuntu-20.04.4-live-server-amd64.iso}   # set default if empty
    f_u20 ${ISO_FILE}
    f_passwordless_ssh ubuntu
  elif [ "${OS}" = "u22" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ubuntu/ubuntu-22.04-live-server-amd64.iso}   # set default if empty
    f_u22 ${ISO_FILE}
    f_passwordless_ssh ubuntu
  else
    f_use
  fi
