
f-check-ip(){
  # This is called by change-ip.sh
  f-marker ${FUNCNAME[0]}
  echo "${NEW_IP}" | grep '192.168.122\.' > /dev/null
  if [ $? -gt 0 ]; then
    echo "Invalid IP ${NEW_IP} . IP must be 192.168.122.X"
    exit 1
  fi
  if [ "${OLD_IP}" = "${NEW_IP}" -o "${NEW_IP}" = "0" ]; then
    echo -e "\nNo IP changed. Old(${OLD_IP}) and new(${NEW_IP}) IP are the same.\n"
    exit
  fi
  bash -xc "ping -c 1 ${NEW_IP} > /dev/null"
  if [ $? -eq 0 ]; then
    echo "\nIP conflict for ${NEW_IP}\n"
    exit 1
  fi
}

