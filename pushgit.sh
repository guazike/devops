commitStr=""
if [ $# -gt 0 ]; then
    commitStr="$1"
else
    commitStr="fix"
fi

git add .
git commit -a -m "$commitStr"
git push

