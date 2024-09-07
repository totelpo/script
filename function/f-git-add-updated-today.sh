f-git-add-updated-today(){
  fn_name=${FUNCNAME[0]}
  p_github_repo="$1";   p_github_repo=${p_github_repo:=default} # default value
  GITHUB_DIR=${GITHUB_DIR:=/github/totelpo}
  v_repo_dir=${GITHUB_DIR}/${p_github_repo}
  v_out=${TMPDIR}/${FUNCNAME[0]}-${p_github_repo}.sh
  f_use(){
    cat << EOF
USAGE : 
${fn_name} GITHUB_REPO
${fn_name} script
${fn_name} demo
EOF
  }
  if [ $# -gt 0 ]; then
    if [ -d ${v_repo_dir} ]; then
      cd ${v_repo_dir}
      v_files_changed_today=$(echo `find -type f -mtime 0 | grep -v '\.git' | sed 's|^\./||' | grep -v '\.swp$' | sort`)
      cat << EOF > ${v_out}
git remote set-url origin git@github.com:totelpo/${p_github_repo}.git
git add ${v_files_changed_today}
git commit -m "Add todays updated/created file/s via ${fn_name} : ${v_files_changed_today}"
git push origin main
EOF
      sh -xc "cat ${v_out}"
    else
      echo "Repo folder does not exists."
      ls -lhd ${v_repo_dir}
    fi
  else
    echo "No repo defined. Check GITHUB_DIR=${GITHUB_DIR}"
    f_use
  fi
}
