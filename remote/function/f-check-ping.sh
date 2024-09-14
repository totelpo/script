f-check-ping(){
  # This is called by change-ip.sh
    f-marker ${FUNCNAME[0]}
    set +e
    bash -xc "ping -c 1 google.com > /dev/null"
    if [ $? -eq 0 ]; then
      echo -e "\nPing test succeed.\n"
    else
      echo -e "\nPing test FAILED.\n"
    fi
 }
