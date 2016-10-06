#!/bin/bash
rsync -aAXv --delete  --exclude-from=/etc/rsync_exclude.lst / /mnt/backup/

