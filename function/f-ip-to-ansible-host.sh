f-ip-to-ansible-host(){
  r_server_id=`echo ${IP} | awk -F'.' '{ print $NF }'`
  r_server_id_pad=$(printf "%03d\n" $r_server_id)
  r_ansible_host=s${r_server_id_pad}
  echo "
# r_server_id     = $r_server_id
# r_server_id_pad = $r_server_id_pad
# r_ansible_host  = ${r_ansible_host}
"
}
