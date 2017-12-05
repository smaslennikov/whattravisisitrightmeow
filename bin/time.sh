#!/bin/bash

set -ex

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"
git remote rm origin
git remote add origin https://${GH_TOKEN}@github.com/smaslennikov/whattravisisitrightmeow.git
git checkout -b muster
git checkout -B master muster

updatetime() {
    echo $nowdate > time.txt
    sed -i'traeish' -e 's&<p can i put a marker here?.*$&<p can i put a marker here?>'"$nowdate"'</p>&' index.html

    commits=$(git shortlog | grep -E '^[^ ]' | grep Travis | sed -e 's/^.*(//g' -e 's/).*//g')
    sed -i'traeish' -e 's&<p can i put another marker here?.*$&<p can i put another marker here?>'"$commits"' minutes committed</p>&' index.html

    git add index.html time.txt
    git commit -m "Can't you see I'm updating the time?"
}

push() {
    cmdpid=$BASHPID
    (sleep 30; kill $cmdpid) &
    git status
    git push origin master
}

nowdate=$(date +"%H %M %Z")
nowhour=$(echo $nowdate | cut -d' ' -f 1 | sed -e 's/^0//g')
nowminu=$(echo $nowdate | cut -d' ' -f 2 | sed -e 's/^0//g')

olddate=$(cat time.txt)
oldhour=$(echo $olddate | cut -d' ' -f 1 | sed -e 's/^0//g')
oldminu=$(echo $olddate | cut -d' ' -f 2 | sed -e 's/^0//g')

if [ "$nowhour" -ne "$oldhour" -o "$nowminu" -ne "$oldminu" ]; then
    updatetime
    push
else
    sleep $((60 - $(date +%-S)))

    nowdate=$(date +"%H %M %Z")
    nowhour=$(echo $nowdate | cut -d' ' -f 1 | sed -e 's/^0//g')
    nowminu=$(echo $nowdate | cut -d' ' -f 2 | sed -e 's/^0//g')

    updatetime
    push
fi
