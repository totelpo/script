
convert -size 1280x720 xc:yellow  ${TMPDIR}/p-ex-720p-horizontal.png
convert -size 720x1280 xc:yellow  ${TMPDIR}/p-ex-720p-vertical.png

<<COMMENT
cd /vm/y/jackie/dcim-huawei6p/mango-graft/

cp -nv 20200911_152506-scion.jpg ${TMPDIR}/p-ex-vertical.jpg
cp -nv 20200922_065254-scion.jpg ${TMPDIR}/p-ex-square.jpg

cp -nv /hd/pix/gione/Camera/IMG_20200916_132137-katnga-puti-day001.jpg ${TMPDIR}/p-ex-horizontal.jpg
COMMENT

ls -lh ${TMPDIR}/p-ex-*
