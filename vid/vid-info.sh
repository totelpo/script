
SELECT_STREAMS=${SELECT_STREAMS:-"v"} # default to video stream

if [ $# -gt 0 ]; then
  if   [ "${SELECT_STREAMS}" = "a" ]; then
    (
    echo "filename,index,codec,channels,sample_rate,duration,bitrate"
    for filename in $@; do
    ffprobe -v error -select_streams ${SELECT_STREAMS} -print_format json -show_streams ${filename} \
    | jq -r '
      .streams[]
      | {
          index,
          codec_name,
          channels,
          sample_rate,
          duration,
          bit_rate
        }
      | [ .index, .codec_name, .channels, .sample_rate, .duration, .bit_rate ]
      | @csv
    ' | sed "s/^/${filename},/" 
    done
    ) 
  elif [ "${SELECT_STREAMS}" = "v" ]; then
    (
    echo "filename,index,codec,width,height,rotation,duration,fps,bitrate"
    for filename in $@; do
    ffprobe -v error -select_streams ${SELECT_STREAMS} -print_format json -show_streams ${filename} \
    | jq -r '
      .streams[]
      | {
          index,
          codec_name,
          width,
          height,
          duration,
          avg_frame_rate,
          bit_rate,
          rotation: (
            ( .side_data_list // [] | map(select(.rotation!=null)) | .[0].rotation )
            // ( .tags.rotate? | tonumber? )
            // 0
          )
        }
      | [ .index, .codec_name, .width, .height, .rotation, .duration, .avg_frame_rate, .bit_rate ]
      | @csv
    ' | sed "s/^/${filename},/" 
    done
    ) 
  fi | awk -F, 'NR==1 { for(i=1;i<=NF;i++) printf i (i==NF ? "\n" : ",") } {print}' `# Add column numbers` \
     | sed 's/"//g' | column -t -s, -o"|" ${HIDE}

else
  cat << EOF
# Usage sample : 
SELECT_STREAMS=v HIDE=-H2,8,9 $(basename $0) VID_20250902_162819.mp4 
EOF

fi

