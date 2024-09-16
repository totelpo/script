#!/bin/bash

# totel 20191113 on hp laptop centos 7.5.1804
# totel 20240916 v2.0 Replace f_get_ip with function f-get-kvm-ip to get IP/s

sc_name=$0
source ${ENV_DIR}/env_function.sh
source ${ENV_DIR}/env_script.sh

p_grep="$1"; p_grep=${p_grep:='.'} # default value

v_tmp=${TMPDIR}/vm-list.txt
v_out=${TMPDIR}/vm-list.out

<< COMMENT
echo "
# Manually clear ARP cache IPs to prevent Old IPs from appearing
# sudo ip -s -s neigh flush all ### clear out the full ARP cache
virsh domiflist <VM-NAME>       # get MAC address
arp -en | grep  <MAC-ADDRESS>   # get IPs
sudo arp -d <IP> # per IP       # Clear ARP cache for specific IP
vm-arp-clear-unreachable-ip.sh
" 
COMMENT

arp -an > $v_tmp.arp

v_cmd="virsh list --all"

echo -e "\n# $v_cmd\n"
eval $v_cmd | sed 's/shut off/shut-off/; /----/d' > $v_tmp
(
echo "`head -1 $v_tmp` | IP | CPU(s) | RAM | Disk usage "
sed '1d' $v_tmp | egrep "$p_grep" | while read i_line; 
do
	v_vm=`echo ${i_line} | awk '{ print $2 }'`
	v_cpu_ram=`virsh dominfo ${v_vm} | grep -e 'CPU(s)' -e 'Used memory:' | awk -F':' '{ print $2 }' | tr -s ' ' | tr '\n' '|' | sed 's/|$//'`
  VM=${v_vm} f-get-kvm-ip > /dev/null
  v_ip=${r_ip}
  v_disk_usage=$(du -sh ${KVM_DIR}/${v_vm} | awk '{ print $1 }')
  echo " ${i_line} | $v_ip | $v_cpu_ram | ${v_disk_usage}"
done | sort -k2 
) | column -t -s'|' -o'|' | tee $v_out

# echo; echo "virsh net-list" | sh -x

echo
ls -lh $v_out
