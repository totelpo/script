f-get-kvm-ip(){
if [ ! -z "${VM}" ]; then 
 #v_mac=`virsh dumpxml   ${VM} | grep "mac address" | head -1 | awk -F\' '{ print $2}'` # another way to get MAC address
  v_mac=`virsh domiflist ${VM} | awk '{ print $5 }' | grep . | sed '1d'`
  v_ips=`arp -an | grep "${v_mac}" | awk '{ print $2}' | sed 's/(//; s/)//'`
  unset r_ip
  if [ ! -z "${v_ips}" ]; then
    if [ $(echo "$v_ips" | wc -w) -gt 1 ]; then
      # echo "The variable contains more than one word."
      for i_ip in ${v_ips}; do
        ping -c 1 ${i_ip} > /dev/null
        if [ $? -eq 0 ]; then
          r_ip="${r_ip} ${i_ip}"
        else
          sh -xc "sudo arp -d $i_ip"
        fi
      done
    else
      r_ip=${v_ips}
    fi

    echo "
# r_ip = $r_ip
IP=$r_ip f-ip-to-server-id  # for r_ansible_host
" 
  else
    echo "KVM guest(${VM}) has no IP: v_ips=${r_ip} ." 
  fi
else
  echo "\nEmpty variable : VM=${VM} \n"
fi
}

