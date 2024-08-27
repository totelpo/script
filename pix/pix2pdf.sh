#!/bin/bash
sc_name=$(basename $0)
sc_name1="${sc_name%.*}" # without extension name

sc_tmp=~/t/${sc_name}.tmp

<<COMMENT
20240816 for github

Legal  612 x 1008
Letter 612 x 792    # We will use this setting in this script
for PDF * Use resolution is 72 dots per inch (DPI), otherwise page print preview will not be correct
COMMENT

if [ $# -lt 1 ]; then
  echo "
totel 20200402
 DESC: Convert pictures (jpeg, etc..) to pdf
USAGE: 
${sc_name} INPUT/s OUTPUT_DIR
${sc_name} 2645-payapag/2645-010\*.jpg for_gdrive_upload
"
else 
  echo 
  p_inputs="$1"; p_inputs=${p_inputs:=mkv} # default value
  p_out_dir="$2"; p_out_dir=${p_out_dir:=for_gdrive_upload} # default value

  v_font=DejaVu-Sans-Mono-Bold
  v_dir_name=`dirname "${p_inputs}"`
  v_out_id=${p_out_dir}/${v_dir_name}
  v_zip=${v_out_id}.zip
  v_list=${v_out_id}.txt
  v_pdf=${v_out_id}.pdf

  if [ ! -d ${v_dir_name} ]; then
    echo output directory ${p_out_dir} does not exists
    exit
  fi

  (
  l1="-resize x792 -extent 612x792 -gravity center"
  echo "
  # NOTE: zip comes fires so that if there are no updated files, the rest will not execute
  # NOTE: convert, ensure -gravity comes first before the input image
  zip -D -u -r ${v_zip}  ${v_dir_name}/* && \\
  convert \\"
  for i in `ls ${p_inputs}`; do
    v_height=`identify -format %h $i`
    v_width=` identify -format %w $i`
    v_pointsize=12
    if [ $v_height -gt $v_width ]; then
       v_resize=x$((792-2*v_pointsize))  # 792-(2*15)
    else
       v_resize=612x
    fi
    b=$(basename $i)
    f="${b%.*}" # without extension name
    # v_text="`echo "$f" | sed 's/./ /5; s/./ /9' | awk '{ print $1,$3 }'`" # for raga picture files
    v_text="$f"
    echo '\( -gravity center '${i}' \
       -resize '${v_resize}' -extent 612x792 \
       -font '${v_font}' -pointsize '${v_pointsize}' -fill white \
       -draw "rectangle 0,'${v_pointsize}' 612,0 gravity north fill rgba(0,0,0,0.9) text 0,0'"'${v_text}'\""' \) \'
  done
  echo "-units pixelsperinch -density 72 -page letter ${v_pdf} && \\
  unzip -l ${v_zip} | tee ${v_list}
  
  ls -lh ${v_out_id}.*
  
  # evince ${v_pdf}
  
  "
  ) | tee ${sc_tmp}

  rm -rf ${v_pdf} ${v_zip}
  source ${sc_tmp}
  echo -e "\n${sc_tmp}\n"
fi

