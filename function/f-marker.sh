f-date-host(){
  if [ "${DEBUG}" = "y" ]; then
    printf "$(date +'%Y-%m-%dT%H:%M:%S%z') $USER@$HOSTNAME"   # Contains more info for debugging
  else
    printf "[$HOSTNAME]"
  fi
}

f-marker (){
p_marker_id="$(echo $@ | sed "s|${HOME}/|~/|g")"
  export TERM=xterm
# MARKER_WIDTH="${MARKER_WIDTH:=100}"   # OR `tput cols`  # MARKER_WIDTH=105 for main script
MARKER_WIDTH="${MARKER_WIDTH:=$((`tput cols`-5))}"   # OR `tput cols`  # MARKER_WIDTH=105 for main script
  v_marker=`eval "printf '#%.0s' {1..$MARKER_WIDTH}"`
 #echo -e "${v_marker}"
  echo -e "\n# $(f-date-host) $p_marker_id $v_marker" | cut -c 1-$MARKER_WIDTH
 #echo -e "${v_marker}"
}
