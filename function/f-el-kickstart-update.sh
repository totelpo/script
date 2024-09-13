f-el-kickstart-update(){
fn_name=${FUNCNAME[0]}
fn_tmp=${TMPDIR}/${fn_name}-tmp
f-marker $fn_name $@

if [ -z ${VM} -o -z ${KS_TMP} -o -z ${NETDEV} -o -z ${PROTO} -o -z ${VM_OS_ADMIN} ] ; then 
	echo -e "\n[ERROR] Empty variable/s found.\n" 
  echo "-z ${VM} -o -z ${KS_TMP} -o -z ${NETDEV} -o -z ${PROTO} -o -z ${VM_OS_ADMIN}"
	cat << EOF
# USAGE : 
# This script is called from kvm-el.sh
VM=c7-070  KS_TMP={TMPDIR}/el7.ks  NETDEV=eth0   PROTO=dhcp ${fn_name} 
VM=c7-070  KS_TMP={TMPDIR}/el7.ks  NETDEV=eth0   PROTO=static  IP=192.168.122.70 ${fn_name} 
EOF
	exit 1
else
	if [ ! -f ${KS_TMP} ]; then
		ls -lh ${KS_TMP}
		sh -xc 'sleep 5'
		exit 1
	fi
	if [ "$PROTO" = "static" ]; then
		 v_ip_param="--ip $IP"
	else
		 v_ip_param=
	fi
  if [ -z ${VM_DOMAIN} ]; then
    v_hostname=$VM
  else
    v_hostname=$VM
  fi
	cat << EOF > $fn_tmp.sh
sed -i "s|^network .*|network --device $NETDEV --bootproto $PROTO $v_ip_param --noipv6 --netmask 255.255.255.0 --gateway 192.168.122.1 --nameserver 192.168.122.1,8.8.8.8 --hostname ${v_hostname}|g" ${KS_TMP}
sed -i "s|osadmin|${VM_OS_ADMIN}|g" ${KS_TMP}
sh -xc "grep '^network' ${KS_TMP}"
EOF
	EXEC=y COLUMNS=95 f-exec-temp-script $fn_tmp.sh
fi
}

