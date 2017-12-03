#!/bin/bash

set -ex

git config user.name travistime
git config user.email travistime@allweretaken.xyz
git config commit.gpgsign false

nowdate=$(date +"%H %M %Z")
olddate=$(cat time.txt)

if [ "$nowdate" -gt "$olddate" ]; then
    updatetime
    push
elif [ "$nowdate" -eq "$olddate" ]; then
    sleep $((60 - $(date +%-S)))
    updatetime
    push
elif [ "$nowdate" -lt "$olddate" ]; then
    echo "Time travel detected, explode quickly"
    rm .travis.yml
    git add .travis.yml
    git commit -m "Good bye cruel world"
    push
fi

updatetime() {
    echo $nowdate > time.txt
    sed -i'traeish' -e 's&<p can i put a marker here?.*$&<p can i put a marker here?>'"$nowdate"'</p>&' index.html

    commits=$(git shortlog | grep -E '^[^ ]' | grep travistime | sed -e 's/^.*(//g' -e 's/).*//g')
    sed -i'traeish' -e 's&<p can i put another marker here?.*$&<p can i put another marker here?>'"$commits"' minutes committed</p>&' index.html

    git add index.html time.txt
    git commit -m "Can't you see I'm updating the time?"
}

push() {
    cmdpid=$BASHPID
    (sleep 30; kill $cmdpid) &
    git pull --rebase origin master
    git push origin master
}
