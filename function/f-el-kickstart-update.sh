f-el-kickstart-update(){
f_tmp_ks_update=/tmp/${FUNCNAME[0]}.tmp
f-message EXECUTING "${FUNCNAME[0]} $1 $2 $3 $4 $5"
echo "-z $VM -o -z $KS_TMP -o -z $NETDEV -o -z $PROTO"
if [ -z $VM -o -z $KS_TMP -o -z $NETDEV -o -z $PROTO ] ; then 
	echo -e "\n[ERROR] Empty variable.\n" 
	cat << EOF
# USAGE : 
# This script is called from kvm-el.sh
VM=c7-070  KS_TMP={TMPDIR}/el7.ks  NETDEV=eth0   PROTO=dhcp ${FUNCNAME[0]} 
VM=c7-070  KS_TMP={TMPDIR}/el7.ks  NETDEV=eth0   PROTO=static  IP=192.168.122.70 ${FUNCNAME[0]} 
EOF
	exit
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
	cat << EOF > $f_tmp_ks_update.sh
sed -i "s|^network .*|network --device $NETDEV --bootproto $PROTO $v_ip_param --noipv6 --netmask 255.255.255.0 --gateway 192.168.122.1 --nameserver 192.168.122.1,8.8.8.8 --hostname $VM.localdomain|g" ${KS_TMP}
sh -xc "grep '^network' ${KS_TMP}"
EOF
	EXEC=y f-exec-temp-script $f_tmp_ks_update.sh
fi
}

