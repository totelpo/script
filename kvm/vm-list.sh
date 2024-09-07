#!/bin/bash

# totel 20191113 on hp laptop centos 7.5.1804

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

f_get_ip(){
	v_ip=- ; v_mac=-
	if [ "$3" = "running" ]; then
		#v_mac=`virsh dumpxml $1 | grep "mac address" | head -1 | awk -F\' '{ print $2}'`
		v_mac=`virsh domiflist $1 | awk '{ print $5 }' | grep . | sed '1d'`      ### another way of getting mac
		v_ip=`grep "$v_mac" $v_tmp.arp | awk '{ print $2}' | sed 's/(//; s/)//' | tr -s '\n' ' '`
	fi
}

v_cmd="virsh list --all"

echo -e "\n# $v_cmd\n"
eval $v_cmd | sed 's/shut off/shut-off/; /----/d' > $v_tmp
(
echo "`head -1 $v_tmp` | IP | CPU(s) | RAM"
sed '1d' $v_tmp | egrep "$p_grep" | while read i; do
	i_vm=`echo $i | awk '{ print $2 }'`
	v_cpu_ram=`virsh dominfo $i_vm | grep -e 'CPU(s)' -e 'Used memory:' | awk -F':' '{ print $2 }' | tr -s ' ' | tr '\n' '|'`
	f_get_ip $i
	echo " $i | $v_ip | $v_cpu_ram"
done | sort -k2 
) | column -t -s'|' -o'|' | tee $v_out

# echo; echo "virsh net-list" | sh -x

echo
ls -lh $v_out
