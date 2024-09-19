# totel 20230303
# cd /nfs/yum-repo/el7/
# ls -lh $(find . -name "*.rpm" -mmin -5 -type f)
# find . -name packages -type l | sort ### find symlinks
### find non-empty dir 
# find . -mindepth 2 -maxdepth 2 -not -empty -name packages -type d | egrep -i 'percona|ps|pxc|pxb'
# find . -mindepth 2 -maxdepth 2 -not -empty -name packages -type d | grep -i mysql
### find empty dir 
# find . -mindepth 2 -maxdepth 2      -empty -name packages -type d | egrep -i 'percona|ps|pxc|pxb'
# find . -mindepth 2 -maxdepth 2      -empty -name packages -type d | egrep -i mysql

f-one-repo-dir-el7-move-rpms-percona(){
	cd /nfs/yum-repo/el7/
	(
	echo "set -e"
	for i in $(find . -mindepth 2 -maxdepth 2 -not -empty -name packages -type d | egrep -i 'percona|ps|pxc|pxb|tools-release'); do
		echo "mv -nv $i/*.rpm all-packages/percona-x86_64/"
		echo "cd $(dirname $i) ;rm -rf packages ;ln -s ../all-packages/percona-x86_64 packages ;cd .." 
	done
	) | tee percona-to-move.txt; echo
	ls -lh  percona-to-move.txt
}
f-one-repo-dir-el7-move-rpms-mysql(){
	cd /nfs/yum-repo/el7/
	(
	echo "set -e"
	for i in $(find . -mindepth 2 -maxdepth 2 -not -empty -name packages -type d | egrep -i 'mysql'); do
		echo "mv -nv $i/*.rpm all-packages/mysql-x86_64/"
		echo "cd $(dirname $i) ;rm -rf packages ;ln -s ../all-packages/mysql-x86_64 packages ;cd .." 
	done
	) | tee mysql-to-move.txt; echo
	ls -lh  mysql-to-move.txt
}
f-one-repo-dir-el7-symlink-empty-packages-dir-percona(){
	cd /nfs/yum-repo/el7/
	(
	echo "set -e"
	for i in $(find . -mindepth 2 -maxdepth 2      -empty -name packages -type d | egrep -i 'percona|ps|pxc|pxb|tools-release'); do
		echo "cd $(dirname $i) ;rm -rf packages ;ln -s ../all-packages/percona-x86_64 packages ;cd .." 
	done | column -t -o' '
	) | tee percona-to-symlink.txt; echo
	ls -lh  percona-to-symlink.txt
}
f-one-repo-dir-el7-symlink-empty-packages-dir-mysql(){
	cd /nfs/yum-repo/el7/
	(
	echo "set -e"
	for i in $(find . -mindepth 2 -maxdepth 2      -empty -name packages -type d | egrep -i 'mysql'); do
		echo "cd $(dirname $i) ;rm -rf packages ;ln -s ../all-packages/mysql-x86_64 packages ;cd .." 
	done | column -t -o' '
	) | tee mysql-to-symlink.txt; echo
	ls -lh  mysql-to-symlink.txt
}

f-one-repo-dir-el7-latest-dl(){
cd /nfs/yum-repo/
ls -lhd el7 $(find ./el7/ -name "*.rpm" -mmin -5 -type f)
echo cd `pwd`
echo find el7 -mmin -5 -type f
}

f-one-repo-dir-non-empty-packages-dir(){
if [ $# -eq 1 ]; then
        i_os_dir=$1
        cd /nfs/yum-repo/
        if [ -d $i_os_dir ]; then
                echo cd `pwd`
                f-exec-command "find $i_os_dir -mindepth 2 -maxdepth 2 -not -empty -name packages -type d | sort"
        else
                ls -lhd $i_os_dir
        fi
else
        cat << EOF
Usage :
${FUNCNAME[0]} OS_DIR
${FUNCNAME[0]} el7 
EOF
fi
}


