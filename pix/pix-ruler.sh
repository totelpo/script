#!/bin/bash
sc_name=$(basename $0)
sc_name1="${sc_name%.*}" # without extension name

v_crop_sample_sh=${TMPDIR}/crop-sh.txt

mkdir -p ${TMPDIR}/p  # output directory

f_use() {
    echo "
No arguments supplied
USAGE :
  $sc_name p_img p_view p_dash_x p_dash_y 
  $sc_name t.jpg n      500      1500
  " | sed "s|$HOME|~|" | column -t
    echo "
NOTE :
p_dash_x and p_dash_y are increment by 500

  ls Screenshot.from.2018.07.*.png | while read l; do echo $sc_name "'$l n; done '"
`f_samples`
" 
exit
}

p_photo="$1"; p_photo=${p_photo:=t.jpg} # default value

set -e
ls -lh ${p_photo}
set +e

b="$(basename $p_photo)"
d="$(dirname $p_photo)"
f="${b%.*}"   # filename
e="${b##*.}"  # extension
v_x=$(identify -format "%w" $p_photo)
v_y=$(identify -format "%h" $p_photo)

f_samples(){
echo '
i='$p_photo'; b="$(basename $i)"; f="${b%.*}"; e="${b##*.}"  # f=filename # e=extension
v_output=${TMPDIR}/p/$f-crop.$e '"
v_x=$v_x
v_y=$v_y
v_dash_length=$v_dash_length "'
x1=750; x2=1700; y1=1500; y2=2950  # edit this coordinates
convert $i -crop $((x2-x1))x$((y2-y1))+$x1+$y1 ${v_output}
# convert $i -crop $((x2-x1))x$((y2-y1))+$x1+$y1 -resize x2160 ${v_output} ; eog ${v_output} # 4K_UHD 16:9 3840x2160 # use for p2v operation
ls ${v_output} | sed "s|$HOME|~|"
'  > $v_crop_sample_sh

echo '
convert /tmp/o1.jpg /tmp/o2.jpg -gravity center -append /tmp/append_vertical.jpg
dpi=72; convert $i -rotate -10 -units PixelsPerInch -density $dpi -crop 400x400+0+0 -resize $((2*dpi)) /tmp/id_2x2.jpg
convert $i  -units PixelsPerInch -density 72 -crop 630x630+70+0 -resize 200 /tmp/id_2x2-for-xournal-pdf-fillup.jpg
convert $i  -units PixelsPerInch -density 72 -resize 100 apo-signiture.png
identify -format '%[EXIF:*Resolution]%hx%w\n' /tmp/id_2x2.jpg

# crop-circle-with-border
pix_crop.sh IMG_20200922_065254.jpg c 1400 400 600 15 /tmp/p y
# crop-square
pix_crop.sh IMG_20200922_065254.jpg s 1400 400 600 15 /tmp/p y

# gimp rotate : Shift + R
# gimp   crop : select area > Alt+i > c(crop)
# gimp    DPI : Alt+i > p(print size)
' > $v_crop_sample_sh.2
  echo
  ls $v_crop_sample_sh* | sed "s|$HOME|~|"
  echo
}

if [ ! $# -gt 0 ]; then
  f_use
fi

if [ $# -gt 0 ]; then
  p_dash_x=$2; p_dash_x="${p_dash_x:=0}"
  p_dash_y=$3; p_dash_y="${p_dash_y:=0}"
# p_increment=$5; p_increment="${p_increment:=50}"
  s=${TMPDIR}/$sc_name.txt

f_pic_ruler(){

j=${i%.*}; 
v_output=${TMPDIR}/p/$f-ruler.$e 

v_increment=$[$v_x/100]
if [ $v_increment -gt 9 ]; then v_increment=$((v_increment/10*10)); fi

v_pointsize=$((v_increment*5/2))  # $[$v_x/40]
v_strokewidth=$((v_increment/5))  # $[$v_x/500]
v_seq_start=$v_increment
v_pos_label=$((v_increment*10))
v_dash_length=$((v_increment*2+10))
v_text_start_x=$[$p_dash_x+$v_dash_length+5]		   # x label
v_text_start_y=$((p_dash_y+v_dash_length+5+v_pointsize/2)) # y label

echo "
  v_x=$v_x
  v_y=$v_y

  v_increment=$v_increment
  p_dash_x=$p_dash_x
  p_dash_y=$p_dash_y
  v_dash_length=$v_dash_length
"
#-fill blue -box white -pointsize $v_pointsize \
convert $p_photo \
 -stroke blue -strokewidth $v_strokewidth \
   -draw "$(for x in $(seq $v_seq_start $v_increment $v_x) ; do
              if [ $(expr $x % $v_pos_label) -eq 0 ]; then
                y2=$[$v_y-10]
              else
                y2=$v_dash_length
              fi
              echo line $x,$[$p_dash_y+10] $x,$[p_dash_y+$y2]
            done)" \
   -draw "$(for y in $(seq $v_seq_start $v_increment $v_y) ; do
              if [ $(expr $y % $v_pos_label) -eq 0 ]; then
                x2=$[$v_x-10]
              else
                x2=$v_dash_length
              fi
              echo line $[$p_dash_x+10],$y $[$p_dash_x+$x2],$y
            done)" \
 -fill white -pointsize $v_pointsize \
   -draw "$(for x in $(seq $v_seq_start $v_increment $v_x) ; do
              if [ $(expr $x % $v_pos_label) -eq 0 ]; then
                echo text $x,$v_text_start_y \"$x\"
              fi
            done)" \
   -draw "$(for y in $(seq $v_seq_start $v_increment $v_y) ; do
              if [ $(expr $y % $v_pos_label) -eq 0 ]; then
                echo text $v_text_start_x,$y \"$y\"
              fi
            done)" \
${v_output}

echo -e "\n${v_output}\n"
f_samples
}

  f_pic_ruler

  echo pix-info.sh ${p_photo} ${v_output} | sed "s|$HOME|~|"
  echo
else
  f_use
fi


