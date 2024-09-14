f-date-host(){
  printf "$(date +'%Y-%m-%dT%H:%M:%S%z') $USER@$HOSTNAME"
}

f-marker (){
p_marker_id="$(echo $@ | sed "s|${HOME}/|~/|g")"
  export TERM=xterm
  MARKER_WIDTH="${MARKER_WIDTH:=100}"   # OR `tput cols`  # MARKER_WIDTH=105 for main script
  v_marker=`eval "printf '#%.0s' {1..$MARKER_WIDTH}"`
  echo -e "\n${v_marker}"
  echo -e "# $(f-date-host) $p_marker_id $v_marker" | cut -c 1-$MARKER_WIDTH
  echo -e "${v_marker}\n"
}
