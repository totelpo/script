f-info-ifcfg()
{
  # This is called by change-ip.sh
  f-marker ${FUNCNAME[0]}
  set +e
  bash -xc "egrep 'BOOTPROTO|IPADDR|PREFIX|GATEWAY|DNS|NETMASK' /etc/sysconfig/network-scripts/ifcfg-${v_dev}"
  set -e
}

