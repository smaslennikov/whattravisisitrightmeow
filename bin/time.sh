#!/bin/bash

set -ex

git config user.name travistime
git config user.email travistime@allweretaken.xyz
git config commit.gpgsign false

nowdate=$(date +"%H %M %Z")
nowhour=$(echo $nowdate | cut -d' ' -f 1)
nowminu=$(echo $nowdate | cut -d' ' -f 2)

olddate=$(cat time.txt)
oldhour=$(echo $olddate | cut -d' ' -f 1)
oldminu=$(echo $olddate | cut -d' ' -f 2)

if [ "$nowhour" -gt "$oldhour" -o ( "$nowminu" -gt "$oldminu" -a "$nowhour" -ge "$oldhour" ) ]; then
    updatetime
    push
elif [ "$nowminu" -eq "$oldminu" -a "$nowhour" -eq "$oldhour" ) ]; then
    sleep $((60 - $(date +%-S)))
    updatetime
    push
elif [ "$nowhour" -lt "$oldhour" -o ( "$nowminu" -lt "$oldminu" -a "$nowhour" -ge "$oldhour" ) ]; then
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
