#!/bin/bash
sc_name=$(basename $0)
sc_name1="${sc_name%.*}" # without extension name

<<COMMENT
20240824 totel Add to https://github.com/totelpo/script
COMMENT

f_use() {
cat << EOF
DESC: Remove photo background 
EOF
  echo "
USAGE: 
$sc_name PICTURE					      FUZZ_VALUE
$sc_name i-green-background.jpg 10        
" | sed "s|$HOME|~|g" | column -t
}


if [ $# -eq 2 ]; then
  p_photo="$1"; p_photo=${p_photo:=mkv} # default value
  p_fuzzval="$2"; p_fuzzval=${p_fuzzval:=10} # 10 gives best result
  s=${TMPDIR}/$sc_name1.s
  b=$(basename $p_photo)
  d=$(dirname $p_photo)
  f="${b%.*}"	# filename
  e="${b##*.}"	# extension
  v_output=${TMPDIR}/p/$f-nobackground.png
  t1=${TMPDIR}/$f.png
  l=${TMPDIR}/l.$sc_name1.log
  
  ww=`convert ${p_photo} -format "%w" info:`
  hh=`convert ${p_photo} -format "%h" info:`
  convert ${p_photo} $t1
  
  # 1000x1600 
  xlast=$((ww-1))
  ylast=$((hh-1))
  
  # get color on four corners
  color1=`convert ${p_photo} -format "%[pixel:u.p{1,1}]" info: `
  color2=`convert ${p_photo} -format "%[pixel:u.p{$xlast,$ylast}]" info: `
  color3=`convert ${p_photo} -format "%[pixel:u.p{1,$ylast}]" info:` 
  color4=`convert ${p_photo} -format "%[pixel:u.p{$xlast,1}]" info:` 
  
  # remove background colors
  convert $t1 -alpha on -channel rgba -fuzz $p_fuzzval% \
  -fill none -opaque "$color1" \
  -fill none -opaque "$color2" \
  -fill none -opaque "$color3" \
  -fill none -opaque "$color4" \
  ${v_output}

  echo pix-info.sh ${p_photo} ${v_output} | sed "s|$HOME|~|"
else 
  f_use
fi
