f-date-host(){
  if [ "${DEBUG}" = "y" ]; then
    printf "$(date +'%Y-%m-%dT%H:%M:%S%z') $USER@$HOSTNAME"   # Contains more info for debugging
  else
    printf "[$HOSTNAME]"
  fi
}

f-marker (){
  p_marker_id="$(echo $@ | sed "s|${HOME}/|~/|g")"
  echo -e "\n# $(f-date-host) ${p_marker_id} ${MARKER}" | cut -c 1-$MARKER_WIDTH
 #echo -e "${MARKER}"
}
