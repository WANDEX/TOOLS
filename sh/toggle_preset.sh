#!/bin/sh
# Toggle between pulseeffects presets
FILE="$HOME"'/.scripts/.temp/.toggle_preset_status.sh'
CURRENT_PRESET_NAME=$( "$FILE" | head -n 1 )

if [[ -z $CURRENT_PRESET_NAME ]]; then
    COLOR_INT='5'
    PRESET='sleep'
elif [[ "$CURRENT_PRESET_NAME" == sleep ]]; then
    COLOR_INT='13'
    PRESET='sleep_2'
elif [[ "$CURRENT_PRESET_NAME" == sleep_2 ]]; then
    COLOR_INT='6'
    PRESET='default'
else
    COLOR_INT='6'
    PRESET='default'
fi

NEW_PRESET_NAME="$PRESET"
# get Xresource color by N
X_RES_COLOR=$( xrdb -query | grep '*.color'"$COLOR_INT" | awk '{print $2}' )

# change preset (real)
pulseeffects -l "$NEW_PRESET_NAME"
# change at pulseeffects GUI (only preset name)
gsettings set com.github.wwmm.pulseeffects last-used-preset "$NEW_PRESET_NAME"

## FOLLOWING ONLY AFTER ABOVE LINES!
# set variable to empty string, to echo empty line only in file
if [[ "$NEW_PRESET_NAME" == default ]]; then NEW_PRESET_NAME=''; fi
# write to file
printf "#!/bin/sh\necho '"$NEW_PRESET_NAME"'\necho '"$X_RES_COLOR"'" > "$FILE"
