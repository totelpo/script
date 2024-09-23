f-info-nmcli()
{
  # This is called by change-ip.sh
  f-marker ${FUNCNAME[0]}
  bash -xc "nmcli con show"
  echo 
  bash -xc "nmcli -t -f IP4 connection show ${v_conn_name}"
}


