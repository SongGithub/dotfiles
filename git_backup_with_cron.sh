#!/bin/sh

COMMIT_LEAD_MSG='daily commit, date time is'
DATE=$(date +"%m-%d-%y")
TIME=$(date +"%r")

COMMIT_MSG=$COMMIT_LEAD_MSG$TIME$DATE
echo 'adding all files to commit...'
git add .
echo 'committing...'
echo '\n'
echo $COMMIT_MSG
ECHO_COMMIT_MSG="commit messege is:$COMMIT_MSG"
echo $ECHO_COMMIT_MSG
git commit -m "$COMMIT_MSG"
echo 'pushing to master branch'
git push origin master