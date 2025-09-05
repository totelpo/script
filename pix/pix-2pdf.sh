#!/bin/bash
sc_name=$(basename $0)
sc_name1="${sc_name%.*}" # without extension name

sc_tmp=${TMPDIR}/${sc_name}.tmp
sc_tmpdir=${TMPDIR}/${sc_name1}

<<COMMENT
20240816 for github
20241107 ISSUE : for PDF * Use resolution is 72 dots per inch (DPI), otherwise page print preview will not be correct
         FIX : Create a temporary file/s to fix issue when v_dpi is 300. v_density must always be 72.
         ENHANCEMENT : Add pagesize options : letter, a4, legal
20241117 totel 
COMMENT

if [ $# -lt 1 ]; then
  echo "
totel 20200402
 DESC: Convert pictures (jpeg, etc..) to pdf
USAGE: 
TEXT_FN=n ${sc_name} INPUT/s                     OUTPUT_DIR         PAPER
TEXT_FN=n ${sc_name} 2645-payapag/2645-010\*.jpg for_gdrive_upload  letter
"
else 
  echo 
  p_inputs="$1"; p_inputs=${p_inputs:=mkv} # default value
  p_out_dir="$2"; p_out_dir=${p_out_dir:=for_gdrive_upload} # default value
  p_paper="$3"; p_paper=${p_paper:=letter} # default value

  v_font=DejaVu-Sans-Mono-Bold
  v_dir_name=`dirname "${p_inputs}"`
  v_out_id=${p_out_dir}/${v_dir_name}
  v_zip=${v_out_id}.zip
  v_list=${v_out_id}.txt
  v_pdf=${v_out_id}.pdf

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
  v_pixel_width=$( echo "${v_paper_width}*${v_dpi}"  | bc | cut -d. -f1)
  v_pixel_height=$(echo "${v_paper_height}*${v_dpi}" | bc | cut -d. -f1)

  if [ ! -d ${v_dir_name} ]; then
    echo Input directory ${v_dir_name} does not exists.
    exit
  fi
  if [ ! -d ${p_out_dir} ]; then
    echo Output directory ${p_out_dir} does not exists.
    exit
  fi

  (
 #l1="-resize x792 -extent 612x792 -gravity center"
  l1="-resize x${v_pixel_height} -extent ${v_pixel_width}x${v_pixel_height} -gravity center"
  echo "
mkdir -p ${sc_tmpdir}
rm -f ${sc_tmpdir}/*.*

# NOTE: zip comes fires so that if there are no updated files, the rest will not execute
# NOTE: convert, ensure -gravity comes first before the input image
zip -D -u -r ${v_zip}  ${v_dir_name}/* && \\
("
  for i_image in `ls ${p_inputs}`; do
    v_height=`identify -format %h ${i_image}`
    v_width=` identify -format %w ${i_image}`
    v_pointsize=$(echo "scale=2; 0.015*${v_pixel_height}" | bc | cut -d. -f1)
    
    if [ $v_height -gt $v_width ]; then
       v_resize=x$((v_pixel_height-2*v_pointsize))
       v_resize=x$((v_pixel_height-2*v_pointsize))  # 792-(2*15)
    else
       v_resize=${v_pixel_width}x
    fi
    v_basename0=$(basename ${i_image})
    v_basename1="${v_basename0%.*}" # without extension name
    if [ "${TEXT_FN}" = "n" ]; then
      unset v_text
    else
      # v_text="`echo "${v_basename1}" | sed 's/./ /5; s/./ /9' | awk '{ print $1,$3 }'`" # for raga picture files
      v_text="${v_basename1}"
    fi
    echo '
convert -gravity center '${i_image}' \
  -resize '${v_resize}' -extent '${v_pixel_width}x${v_pixel_height}' \
  -font '${v_font}' -pointsize '${v_pointsize}' -fill white \
  -draw "rectangle 0,'${v_pointsize}' '${v_pixel_width}',0 gravity north fill rgba(0,0,0,0.9) text 0,0'"'${v_text}'\""' \
'${sc_tmpdir}/${v_basename0}
  done
  echo "
convert ${sc_tmpdir}/*.* -units pixelsperinch -density ${v_density} -page ${p_paper} ${v_pdf}
) && \\
unzip -l ${v_zip} | tee ${v_list}
  
ls -lh ${v_out_id}.*
  
# evince ${v_pdf}
  
"
  ) | tee ${sc_tmp}

  rm -rf ${v_pdf} ${v_zip}
  source ${sc_tmp}
  echo -e "\n${sc_tmp}\n"
fi

