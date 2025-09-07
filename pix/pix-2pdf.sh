#!/bin/bash
sc_name=$(basename $0)
sc_name1="${sc_name%.*}" # without extension name

sc_tmp=${TMPDIR}/${sc_name1}.tmp.sh
sc_tmpdir=${TMPDIR}/${sc_name1}

<<COMMENT
20240816 for github
20241107 ISSUE : for PDF * Use resolution is 72 dots per inch (DPI), otherwise page print preview will not be correct
         FIX : Create a temporary file/s to fix issue when v_dpi is 300. v_density must always be 72.
         ENHANCEMENT : Add pagesize options : letter, a4, legal
20250906 major rewrite: Use file list instead of a files as input parameter
COMMENT

DIR=${DIR:-5815-paulba}

if [ $# -lt 3 ]; then
cat << EOF
#  DESC: Convert list of pictures (jpeg, etc..) to pdf
# USAGE: 
ls ${DIR}/*.* > ${DIR}.list

EOF
cat << EOF | column -t -o' '
DIR=${DIR} EXEC=n INCLUDE_FILENAME=n ${sc_name} PHOTO_LIST OUTPUT_PDF      PAPER 
DIR=${DIR} EXEC=y INCLUDE_FILENAME=y ${sc_name} ${DIR}.list  ${DIR}.pdf a4
EOF
cat << EOF

zip -D -u -r ${DIR}.zip  ${DIR}/*
unzip -l ${DIR}.zip > ${DIR}-zip.list
EOF
else 
  echo 
  p_photo_list="$1"; p_photo_list=${p_photo_list:=photo.list} # default value
  p_out_pdf="$2"; p_out_pdf=${p_out_pdf:=/tmp/photo.pdf} # default value
  p_paper="$3"; p_paper=${p_paper:=letter} # default value

  v_font=DejaVu-Sans-Mono-Bold

  v_dpi=300
  v_density=72   ## v_density must always be 72 regardless of the value of v_dpi
  if [ "$p_paper" = "a4" ]; then
    v_paper_width=8.27
    v_paper_height=11.69
  elif [ "$p_paper" = "legal" ]; then
    v_paper_width=8.5
    v_paper_height=14
  else # p_paper=letter
    v_paper_width=8.5
    v_paper_height=11
  fi
  paper_width_over_height=$(echo "1000*${v_paper_width}/${v_paper_height}" | bc)

  v_pixel_width=$( echo "${v_paper_width}*${v_dpi}"  | bc | cut -d. -f1)
  v_pixel_height=$(echo "${v_paper_height}*${v_dpi}" | bc | cut -d. -f1)

  echo "Generating temporary script ${sc_tmp}"
  (
  l1="-resize x${v_pixel_height} -extent ${v_pixel_width}x${v_pixel_height} -gravity center"
  echo "
mkdir -p ${sc_tmpdir}
rm -f ${p_out_pdf} ${sc_tmpdir}/*.*

# NOTE: convert, ensure -gravity comes first before the input image
(
set -e
"
  for i_image in `cat ${p_photo_list}`; do
    set -e
    if [ ! -f ${i_image} ]; then
      ls -lh ${i_image}
    fi
    set +e
    v_height=`identify -format %h ${i_image}`
    v_width=` identify -format %w ${i_image}`
    v_pointsize=$(echo "scale=2; 0.015*${v_pixel_height}" | bc | cut -d. -f1)
    v_width_over_height=$(echo "1000*${v_width}/${v_height}" | bc)
    
    if [ $v_width_over_height -lt $paper_width_over_height ]; then
      v_resize=x$((v_pixel_height-2*v_pointsize))
      if [ "${INCLUDE_FILENAME}" = "n" ]; then
        v_resize=x$((v_pixel_height))
      fi
    else
      v_resize=${v_pixel_width}x
    fi
    v_basename0=$(basename ${i_image})
    v_basename1="${v_basename0%.*}" # without extension name
    if [ "${INCLUDE_FILENAME}" = "n" ]; then
      unset v_text
      unset v_draw
      v_rectangle_y=0
    else
      v_text="${v_basename0}"
      v_rectangle_y=${v_pointsize}
      v_draw='\
  -font '${v_font}' -pointsize '${v_pointsize}' -fill white \
  -draw "rectangle 0,'${v_rectangle_y}' '${v_pixel_width}",0 gravity north fill rgba(0,0,0,0.9) text 0,0'"${v_text}"'"'"'
    fi

    echo '
convert -gravity center '${i_image}' \
  -resize '${v_resize}' -extent '${v_pixel_width}x${v_pixel_height}' '"$v_draw"' \
'${sc_tmpdir}/${v_basename0}
  done
  v_photo_list2=${sc_tmp}.list2
  cat << EOF

cat ${p_photo_list} | awk -F\/ '{ print "${sc_tmpdir}/"\$NF }' > ${v_photo_list2}

convert \$(cat ${v_photo_list2}) -units pixelsperinch -density ${v_density} -page ${p_paper} ${p_out_pdf}
)
  
ls -lh ${p_out_pdf}
  
# evince ${p_out_pdf}
EOF
  ) > ${sc_tmp}

  if [ "${EXEC}" = "y" ]; then
    echo -e "\n# Executing temporary script."
    bash ${sc_tmp}
  else
    echo -e "\n# Review then execute temporary script."
    echo bash ${sc_tmp}
  fi
fi

