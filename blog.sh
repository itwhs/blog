#!/bin/bash
# 部署到 github pages 脚本
#rm -rf .git/
# Add changes to git.
git init
git add -A
# Commit changes.
msg="building site `date`"
if [ $# -eq 1 ]
	  then msg="$1"
fi
git commit -m "$msg"
git config http.postBuffer 5242880000
# 推送到github
# blog 只能使用 master分支
git push -f git@github.com:itwhs/blog.git master
