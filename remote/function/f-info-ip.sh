f-info-ip()
{
  # This is called by change-ip.sh
  f-marker ${FUNCNAME[0]}
  bash -xc "ip -4 addr show  dev ${NETWORK_DEVICE}"
  echo
  bash -xc "lshw -class network -short"
}

