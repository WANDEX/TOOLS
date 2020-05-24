#!/bin/sh
if [ "* index: 0" == "$(pacmd list-sinks | grep "*" | sed 's/^ *//')" ];
    then pacmd set-default-sink 1;
    SINK=1;
    OUT_STR="MONO";
else
    pacmd set-default-sink 0;
    SINK=0;
    OUT_STR="";
fi;

printf "#!/bin/sh\necho $OUT_STR" > "$SCRIPTS/.temp/.toggle_mono_status.sh"

pacmd list-sink-inputs | grep index | grep -o '[0-9]*' | while read -r line;
    do pacmd move-sink-input $line $SINK;
done;
