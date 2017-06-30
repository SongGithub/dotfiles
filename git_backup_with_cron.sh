#!/bin/sh

COMMIT_LEAD_MSG='daily commit, date time is'
DATE=$(date +"%m-%d-%y")
TIME=$(date +"%r")

echo '\n'
COMMIT_MSG=$COMMIT_LEAD_MSG' '$TIME'  '$DATE
echo 'adding all files to commit...'
echo '\n'
git add .


echo 'committing...'
# echo $COMMIT_MSG
ECHO_COMMIT_MSG="commit messege is:$COMMIT_MSG"
# echo $ECHO_COMMIT_MSG
git commit -m "$COMMIT_MSG"
echo '\n'


echo 'pushing to master branch'
git push origin master
echo '\n'