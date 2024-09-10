#!/bin/bash
# totel 20201127
# totel 20240903 added to github repo
#                Tested on el9 el8
set -e   # exit script when error occurs
sc_name=$0

source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

v_log=${TMPDIR}/$sc_name2.log


f_use() {
  echo "
 DESC: create virtual machine template with any hostname and IP
USAGE: 
$sc_name1 TEMPLATE VM_NAME   IP              p_exec p_disk_gb
$sc_name1 el5      el5-050   192.168.122.50
$sc_name1 el6      el6-060   192.168.122.60
$sc_name1 el7      el7-070   192.168.122.70
$sc_name1 el8      el8-080   192.168.122.80  n       20
$sc_name1 el9      el9-090   192.168.122.90  n       20
$sc_name1 el9      el9-095   192.168.122.95  n       80   ### 80GB disk storage for Minikube
$sc_name1 u16      u16-016   192.168.122.16
$sc_name1 u20      u20-020   192.168.122.20
$sc_name1 u22      u22-022   192.168.122.22

# VM el5|el6|el7|el8
# ls ${SCRIPT_DIR}/kvm/kvm-el.sh # Edit for ISO location

" | sed "s|$HOME|~|g"

exit
}

l=${TMPDIR}/${sc_name2}.l

p_os="$1"       ; p_os=${p_os:=el6}         
p_vm_name="$2"  ; p_vm_name=${p_vm_name:=c6n62}
p_ip="$3"       ; p_ip=${p_ip:=192.168.122.62}         
p_exec="$4"     ; p_exec=${p_exec:=n}         
p_disk_gb="$5"  ; p_disk_gb=${p_disk_gb:=20}         

v_sh=${sc_tmp}.${p_vm_name}.sh

v_ip_last=`echo $p_ip | awk -F'.' '{ print $NF }'`
v_ip_last_padded=`printf "%03d" $v_ip_last`
v_ansible_host=s$v_ip_last_padded


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
f_update_kickstart(){
	p_network_device=$1 ; p_network_device=${p_network_device:=eth0}
	sed -i "s|^network .*|network --device $p_network_device --bootproto static --noipv6 --ip $p_ip --netmask 255.255.255.0 --gateway 192.168.122.1 --nameserver 192.168.122.1,8.8.8.8 --hostname ${p_vm_name}.kvmpo.local|g" $p_kickstart_dir/$p_kickstart_file
}

if [ $# -eq 5 ]; then
	v_dir=${KVM_DIR}/${p_vm_name}
	mkdir -p $v_dir
  set +e
	f_checks(){
		f-check-if-vm-exists       ${p_vm_name}
		f-check-if-kvm-ip-is-valid $p_ip
		f-check-if-ip-in-used      $p_ip
		f-check-if-similar-vm-exists-based-on-ip $p_ip
		f-check-if-dir-is-empty $v_dir
	}
# f_checks # move to kvm-el.sh

	v_img_root=$v_dir/root.img

f_passwordless_ssh(){
	f-marker ${FUNCNAME[0]}
	v_os_user="$1"  ; v_os_user=${v_os_user:=root}
	set -e
	f-get-kvm-ip ${p_vm_name} # return r_ip
	echo; ssh-keygen -f "/home/totel/.ssh/known_hosts" -R "$r_ip"
	echo
	v_ip=$r_ip
	if [ "${p_os}" = "el5" ]; then
		ssh-copy-id -i /home/totel/.ssh/id_rsa_kvm -o HostKeyAlgorithms=+ssh-rsa $v_os_user@$v_ip
	else
		ssh-copy-id -i /home/totel/.ssh/id_rsa_kvm $v_os_user@$v_ip
	fi
	echo -e "\n# Try connecting by :\nssh -i /home/totel/.ssh/id_rsa_kvm $v_os_user@$v_ip\n"
}
f_template_sh(){
	f-marker ${FUNCNAME[0]}
	echo "cd ~/d/scripts/ansible/sh/" | sh -x
	l=$v_log.$sc_name1.${p_vm_name}
	p_os_sh=$1
	v_cmd="vm-template-sh.sh $p_ip ${p_os}_sh 2"
	echo -e "\n# Executing # $v_cmd\n"
	echo -e "\n# Log # $l\n"
	eval "$v_cmd" 2>&1 &> $l
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
	f_update_kickstart eth0
	virt-install \
		--network bridge:virbr0 \
		--name ${p_vm_name} \
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
	f_update_kickstart eth0
	virt-install \
		--network bridge:virbr0 \
		--name ${p_vm_name} \
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
		--name ${p_vm_name} \
		--ram 1024 \
		--disk path=$v_dir/root.img,size=20,bus=virtio \
		--vcpus 1 \
		--os-variant ubuntu16.04 \
		--network bridge:virbr0,model=virtio \
		--graphics none \
		--location $1,kernel=install/vmlinuz,initrd=install/initrd.gz \
		--extra-args 'console=ttyS0,115200n8'
	echo "
ssh ubuntu@$p_ip

# to enable virsh console access to ubuntu 16 guest.  
# https://www.cyberciti.biz/faq/how-to-enable-kvm-virsh-console-access-for-ubuntu-linux-vm/
systemctl enable serial-getty@ttyS0.service
systemctl start serial-getty@ttyS0.service

cp -nv /etc/network/interfaces /etc/network/interfaces.bkp

# vi /etc/network/interfaces
iface ens2 inet static
        address $p_ip
        netmask 255.255.255.0
        gateway 192.168.122.1
dns-nameservers 192.168.122.1 8.8.8.8

# /etc/init.d/networking restart
# apt install iputils-ping
"

	#	--console pty,target_type=serial \
}
######################
f_u20(){
	f-marker ${FUNCNAME[0]}
	f_echo_ubuntu
	echo "sleep 9" | sh -x
	virt-install \
		--name ${p_vm_name} \
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
		--name ${p_vm_name} \
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
EXEC=y VM=${p_vm_name} f-kvm-${p_os} 1
echo 'grep PermitRootLogin /etc/ssh/sshd_config  ### systemctl restart sshd '
vm-arp-clear-unreachable-ip.sh
f-passwordless-ssh ${p_os} ${p_vm_name} root
f-ansible-hosts-kvm
#f-ansible-template            ${p_os} ${p_vm_name}
#EXEC=y f-ansible-repo-mysql-yum-install  ${p_vm_name} ${p_os}
#f-ansible-repo-list-enabled         ${p_vm_name} 
f-get-ansible-ip                    ${p_vm_name}   # return r_ip
vm-copy-scripts.sh                  \$r_ip
vm-change-hostname-ip-p1.sh   ${p_os} ${p_vm_name} $p_ip
vm-arp-clear-unreachable-ip.sh
f-ansible-hosts-old
EOF
	if [ "$p_exec" = y ]; then
		f-exec-temp-script ${v_sh}.tmp
	else
		echo -e "\nf-exec-temp-script ${v_sh}.tmp"
	fi
}
f_el_x(){
  if [ "${p_os}" = "el8" -o "${p_os}" = "el9" ]; then
	cat << EOF > ${v_sh}.tmp
EXEC=y VM=${p_vm_name} OS=${p_os} KS=${p_os}.ks PROTO=static IP=$p_ip DISK_GB=$p_disk_gb RAM_GB=2 CPU=2 kvm-el.sh 
EOF
  else
	cat << EOF > ${v_sh}.tmp
EXEC=y VM=${p_vm_name} KS=${p_os}.ks PROTO=static IP=$p_ip f-kvm-${p_os} 1
EOF
  fi
	cat << EOF >> ${v_sh}.tmp

f-passwordless-ssh ${p_os} ${p_ip}
f-ansible-template            ${p_os} ${v_ansible_host}
IP=${p_ip} vm-os-admin-set-env.sh
IP=${p_ip} vm-copy-scripts.sh
ANSIBLE_COMMAND_WARNINGS=false ansible ${v_ansible_host} -a 'yum repolist enabled'
# EXEC=y f-ansible-repo-percona-yum-install  ${v_ansible_host}            n
# EXEC=y f-ansible-repo-mysql-yum-install    ${v_ansible_host} ${p_os} ''   n
# EXEC=y f-ansible-repo-mmariadb-yum-install ${v_ansible_host} ${p_os} 11.2 n
EOF
	if [ "$p_exec" = y ]; then
		f-exec-temp-script ${v_sh}.tmp
	else
		echo -e "\nf-exec-temp-script ${v_sh}.tmp"
	fi
}
######################

	if [ "${p_os}" = "el5" ]; then
    ISO_FILE=${ISO_FILE:=/iso/centos/5/CentOS-5.11-x86_64-bin-DVD-1of2.iso}   # set default if empty
		f_el5 ${ISO_FILE}
		f-ssh-config-el5
		f_passwordless_ssh 
		f_template_sh el5-template.sh
	elif [ "${p_os}" = "el6" ]; then
    ISO_FILE=${ISO_FILE:=/iso/centos/6/CentOS-6.10-x86_64-bin-DVD1.iso}   # set default if empty
		f_el6 ${ISO_FILE}
		f-ssh-config-el6
		f_passwordless_ssh
		f_template_sh el6-template.sh
	elif [ "${p_os}" = "el7" ]; then
		f_el_x
	elif [ "${p_os}" = "el8" ]; then
		f_el_x
	elif [ "${p_os}" = "el9" ]; then
		f_el_x
	elif [ "${p_os}" = "u16" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ubuntu/ubuntu-16.04.7-server-amd64.iso}   # set default if empty
		f_u16 ${ISO_FILE}
		f_passwordless_ssh ubuntu
		vm-change-hostname-ip-p1.sh  u16 u16-016 $p_ip
	elif [ "${p_os}" = "u20" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ubuntu/ubuntu-20.04.4-live-server-amd64.iso}   # set default if empty
		f_u20 ${ISO_FILE}
		f_passwordless_ssh ubuntu
	elif [ "${p_os}" = "u22" ]; then
    ISO_FILE=${ISO_FILE:=/iso/ubuntu/ubuntu-22.04-live-server-amd64.iso}   # set default if empty
		f_u22 ${ISO_FILE}
		f_passwordless_ssh ubuntu
	else
		f_use
	fi
else
  f_use
fi
