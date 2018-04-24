#!/bin/bash

SYNC_COMMAND="/usr/bin/rclone sync /opt/backup GDrive:/server-backup";
BACKUP_PATH="/opt/backup";

set -e;

function copy {
	if [ ! -d $2 ]; then
		mkdir -p $2;
	fi
	cp -R $1 $2; 
}

# GitLab
/opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1;
copy /etc/gitlab $BACKUP_PATH/gitlab/config;

# Mastodon
sudo -u postgres pg_dumpall > $BACKUP_PATH/pg_dump;
copy /home/mastodon/live $BACKUP_PATH/mastodon;

# Standard File
copy /var/standardfile $BACKUP_PATH/standardfile;

# Nginx
copy /etc/nginx $BACKUP_PATH/nginx;

# Sync backups
$SYNC_COMMAND;
