f-date-host(){
  printf "$(date +'%Y-%m-%dT%H:%M:%S%z') $USER@$HOSTNAME"
}

f-marker (){
  p_marker_id="$@"
  export TERM=xterm
  COLUMNS="${COLUMNS:=100}"   # OR `tput cols`  # COLUMNS=105 for main script
  v_marker=`eval "printf '#%.0s' {1..$COLUMNS}"`
  echo -e "\n${v_marker}"
  echo -e "# $(f-date-host) $p_marker_id $v_marker" | cut -c 1-$COLUMNS
  echo -e "${v_marker}\n"
}
