#!/bin/sh
DEFBACKUPDIR=$"/mnt/arch100Gbackup/LAST/"
DATE_NOW=$(date +"%y-%m-%d")
SOURCE_DIR=$"/" #what directory to backup, / - means root directory
MOUNT_POINT=$"/mnt/arch100Gbackup/" #your mounting point
DEST_DIR=$"$MOUNT_POINT$DATE_NOW/"  #backup destination directory
UUID=$"912ef2eb-7f30-4396-a300-5d91b46c79eb" #your backup device UUID


rsync_oneliner () {                 #ensure that you have 'rsync' installed
    rsync -aAXv --delete --exclude=/dev/* \
    --exclude=/proc/* --exclude=/sys/* \
    --exclude=/tmp/* --exclude=/run/* \
    --exclude=/mnt/* --exclude=/media/* \
    --exclude="swapfile" --exclude="lost+found" \
    --exclude=".cache" --exclude="Downloads" \
    --exclude=".VirtualBoxVMs" --exclude=".ecryptfs" \
    "$1" "$2"
}

isUUIDExist () { lsblk -o UUID|grep "$1"; }

negativeResponse () { printf "Response:(%s). Exiting program.\n" "$1"; exit 1; }

doUmount () {
    printf "Backup device '$UUID' is already mounted!\n"
    printf "'umount UUID=$UUID'.\nI can do that for you!\n"
    umount_response=
    printf "Umount device '$UUID' from '$MOUNT_POINT' mount point? \n(y/n) > "
    read umount_response
    if [ "$umount_response" != "y" ]; then
        printf "Umount aborted. Please make it manually.\n"
        printf "'umount UUID=$UUID'\n"
        negativeResponse "$umount_response"
    else
        umount -v UUID=$UUID
        printf "$UUID umounted\nRelaunch script if you wish to make backup.\n"
        printf "Farewell.\n"
    fi
}


if isUUIDExist "$UUID" == "$UUID"; then
    mount_response=
    printf "Today is: '$DATE_NOW' and it will be your backup directory.\n"
    #printf "!!!ENSURE THAT YOU PLUGGED IN BACKUP DEVICE!!!\n"
    printf "Mount device '$UUID' to '$MOUNT_POINT' mount point? \n(y/n) > "
    read mount_response
    if [ "$mount_response" != "y" ]; then
        printf "Mount canceled by user\n"
        negativeResponse "$mount_response"
    else
        mount -v UUID=$UUID $MOUNT_POINT
        mkdir -pv $DEST_DIR # -p ensures creation if directory does not exist

        start_response=
        printf "START BACKUP PROCESS? \n(y/n) > "
        read start_response
        if [ "$start_response" != "y" ]; then
            printf "Backup process not started\n%s\n" "$DEST_DIR"
            printf "Deleting newly created directory.\n"
            rmdir $DEST_DIR
            doUmount
            negativeResponse "$start_response"
        else
            rsync_oneliner $SOURCE_DIR $DEST_DIR

            LS=$(ls -Fas --color=auto $DEST_DIR)
            printf "\n%s\n" "$LS"
            TOTAL_MP=$(du -ah --max-depth=1 $MOUNT_POINT | tr '\0' '\n')
            printf "\n%s\n" "$TOTAL_MP"
            printf "...DONE...\n\n"
            doUmount
        fi
    fi
else
    printf "\nUUID:'$UUID'\nDoes not exist\n"
fi
