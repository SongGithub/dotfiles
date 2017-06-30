#!/bin/sh

COMMIT_MSG=123
echo 'adding all files to commit'
git add .
echo 'committing...'
echo 'commit messege is: $COMMIT_MSG'
git commit -m $COMMIT_MSG
echo 'pushing to master branch'
git push origin master