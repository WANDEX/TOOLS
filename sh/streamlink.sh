#!/bin/sh
URL="$1"
QUALITY="$2"

# set QUALITY by the secondary argument
if [[ -z "$QUALITY" ]]; then
    QUALITY="best"
elif [[ "$QUALITY" == 60 ]]; then
    QUALITY="720p60"
elif [[ "$QUALITY" == a ]]; then
    QUALITY="audio_only"
else
    QUALITY="720p"
fi

# check URL for substring
if [[ "$URL" == *"twitch"* ]]; then
    TITLE='{author} - {category} -- {title}'
elif [[ "$URL" == *"goodgame"* ]]; then
    basename=$(basename "$URL")
    TITLE="$basename"
else
    TITLE='{url}'
fi

TITLE+=' | ['"$QUALITY"']'
COMMAND=$(screen -dm streamlink --title "$TITLE" "$URL" "$QUALITY")
