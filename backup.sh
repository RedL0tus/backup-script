#!/bin/bash

SYNC_COMMAND="/usr/bin/rclone sync /opt/backup GDrive:/server-backup";

set -e;

function copy {
	if [ ! -d $2 ]; then
		mkdir -p $2;
	fi
	cp -R $1 $2; 
}

# GitLab
/opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1;
copy /etc/gitlab /opt/backup/gitlab/config;

# Mastodon
sudo -u postgres pg_dumpall | gzip /opt/backup/pg_dump.gz;
copy /home/mastodon/live /opt/backup/mastodon;

# Standard File
copy /var/standardfile /opt/backup/standardfile;

# Nginx
copy /etc/nginx /opt/backup/nginx;

# Sync backups
$SYNC_COMMAND;
