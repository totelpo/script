f-get-kvm-ip(){
if [ ! -z "${VM}" ]; then 
  v_mac=`virsh domiflist ${VM} | awk '{ print $5 }' | grep . | sed '1d'`
  r_ip=`arp -an | grep "${v_mac}" | awk '{ print $2}' | sed 's/(//; s/)//'`
  if [ ! -z "${r_ip}" ]; then
    echo -e "# r_ip = $r_ip "
    IP=$r_ip f-ip-to-server-id
  else
    echo "KVM guest(${VM}) has no IP: r_ip=${r_ip} ." 
  fi
else
  echo "\nEmpty variable : VM=${VM} \n"
fi
}

