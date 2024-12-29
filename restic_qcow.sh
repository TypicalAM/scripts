#!/bin/bash
REPO="/mnt/temp/restic"
FILE="/mnt/virt/images/win11/win11.qcow2"
PASSWORD_FILE="/tmp/restic"

pass ResticPassword >/tmp/restic
sshfs poznan-server:/mnt/drive/backups /mnt/temp
restic -r $REPO --password-file $PASSWORD_FILE backup $FILE
umount /mnt/temp
