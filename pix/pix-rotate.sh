#!/bin/bash
sc_name=$(basename $0)   # ${FUNCNAME[0]}
sc_name1="${sc_name%.*}" # w/o extenstion

set -e # enable script exit-on-error and return an exit status you can check with $?  ## set +e # to disable

f_use() {
# DESC: totel 2022
# USAGE: 
  echo "
$sc_name PIX ANGLE
" | sed "s|$HOME|~|g"
exit
}
if [ "$1" = "h" ]; then f_use; fi

if [ $# -eq 2 ]; then
  p_photo="$1"; p_photo=${p_photo:=t.jpg} # default value
  p_angle="$2"; p_angle=${p_angle:=90} # default value
  b="$(basename $p_photo)"
  d="$(dirname $p_photo)"
  f="${b%.*}"	# filename
  e="${b##*.}"	# extension
  v_output=${TMPDIR}/p/$f-rotated.$e

  convert ${p_photo} -rotate $p_angle ${v_output}
  echo pix-info.sh ${p_photo} ${v_output} | sed "s|$HOME|~|"
else
     f_use
fi
