#!/bin/bash
sc_name=$(basename $0)   # ${FUNCNAME[0]}
sc_name1="${sc_name%.*}" # w/o ext

sc_dir=$(dirname $0)

f_use(){
  echo "
USAGE: 
$sc_name PICTURE TEXT GRAVITY TEXT_SIZE_PCT WxH VIEW
$sc_name p.jpg   text center  6             WxH n
"'
'$sc_name' IMG_20200911_080441.jpg "`echo -e "\nCalamansi Marcotted\nfb.com/TotsTanim"`" south 5 960x540 y

'"$v_choices"
}

v_choices="`cat ${sc_dir}/aspect-ratio-pix.txt | grep 16:9`"

if [ $# -gt 3 ]; then
  p_input="$1"
  p_text_north="$2"; p_text_north=${p_text_north:='TotsPo'} # default value
  p_gravity="$3"   ; p_gravity=${p_gravity:=center} # default value
  p_ps_pct1="$4"  # pointsize percentage up
  p_wxh="$5"; p_wxh=${p_wxh:=n} # default value
  p_view="$6"; p_view=${p_view:=n} # default value
  b=$(basename ${p_input})
  d=$(dirname ${p_input})

  if [ ! -f "${p_input}" ]; then
    echo "File does not exists."
    ls -lh ${p_input}
    exit
  fi


  v_list="`echo "$v_choices" | grep "16:9" | awk '{ print $3 }'`"
 #echo $v_list
  if [[ "$p_wxh" =~ $(echo ^\($(echo $v_list | tr " " "|")\)$) ]]; then
    echo > /dev/null # "$p_wxh resolution is in the list"
  else
    echo -e "\nPlease select from the following resolutions: \n $v_choices"
    echo $v_choices | grep "16:9" | awk '{ print $3 }' | tr " " "|"
    exit
  fi

  d2=$(basename `pwd`)
  v_outdir=${TMPDIR}/wm

  mkdir -p $v_outdir
  
  f="${b%.*}"   # filename without extension
  e="${b##*.}"  # file extension
  o=$v_outdir/$f-wm720p.jpg
  
  v_wh=`echo $p_wxh | cut -dx -f 1`
  convert ${p_input} -resize ${v_wh}x${v_wh} $o.1
  h=$(identify -format "%h" $o.1) # height
  w=$(identify -format "%w" $o.1) # width

v_dt1=`identify -format '%[EXIF:*]' ${p_input} | sed 's/exif://' | grep DateTimeOriginal= | sed 's/:/-/g; s/=/ /' | awk '{ print $2 }'`

if [ -z "$v_dt1" ]
then
  v_dt2=
else
  v_dt2=`date -d$v_dt1 +"%Y%b%d"`
fi


v_text_north="`echo -e "$v_dt2$p_text_north"`"


v_ps1=$((h*p_ps_pct1/100))    # pointsize text up
v_sw=$((h/500))      # strokewidth
  
if [ "$v_os" = android ]; then
  v_font=Noto-Sans-Myanmar-UI-Bold
else
  v_font=Liberation-Sans-Bold
fi

  if [ "$p_gravity" = south -o "$p_gravity" = north ]; then
    v_text_geometry="0,$v_ps1"
  elif [ "$p_gravity" = east -o "$p_gravity" = west ]; then
    v_text_geometry="$v_ps1,0"
  else
    v_text_geometry="0,0"
  fi

    convert $o.1 -font $v_font \
      -pointsize $v_ps1 -fill yellow -stroke black -strokewidth $v_sw -draw "gravity $p_gravity text $v_text_geometry '$v_text_north'" \
     $o && rm $o.1
  
# echo -e "\nheight : $h\n"
  ls -lh $o | sed "s|$HOME|~|"
  
  if [ $p_view = y ]; then
    eog $o
  fi
else
  f_use
fi


