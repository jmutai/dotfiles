#!/bin/sh
playstat=`cmus-remote -Q | grep 'status playing'`

if [[ $playstat ]]; then
    artist=`cmus-remote -Q | grep 'tag artist' | cut -d ' ' -f 3-`
    album=`cmus-remote -Q | grep 'tag album ' | cut -d ' ' -f 3-`
    song=`cmus-remote -Q | grep 'tag title' | cut -d ' ' -f 3-`
    combo=$(echo "$artist - $album - $song" | cut -c1-60)

    echo -e "{\"text\":\""🎶 $combo"\", \"class\":\"""\"}"
fi
