f-umount-all-nfs(){
  # This function is called by change-ip.sh
  f-marker ${FUNCNAME[0]} 
  for i in $(mount | grep ' type nfs' | awk '{ print $3 }' ); do
    bash -xc "sudo umount -l $i"
  done
}
