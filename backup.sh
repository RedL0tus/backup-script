#!/bin/bash

RCLONE_REMOTE="GDrive:/server-backup";
BACKUP_PATH="/opt/backup";

set -e;

function COPY {
	if [ ! -d $2 ]; then
		rm -Rf $2;
	fi
	mkdir -p $2;
	cp -R $1 $2; 
}

function BACKUP {
	# GitLab
	echo ">>> Backing up GitLab files..."
	/opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1;
	COPY /etc/gitlab/* $BACKUP_PATH/gitlab/config;

	# Mastodon
	echo ">>> Backing up Mastodon (and dumping PostgreSQL)...";
	/bin/su - postgres -c "/usr/bin/pg_dumpall" > $BACKUP_PATH/pg_dump;
	COPY /home/mastodon/live/.env.production $BACKUP_PATH/mastodon/env.production;

	# Standard File
	echo ">>> Backing up StandardFile...";
	COPY /var/standardfile/* $BACKUP_PATH/standardfile;

	# Nginx
	echo ">>> Backing up nginx config...";
	COPY /etc/nginx/* $BACKUP_PATH/nginx;

	# pakreqBot
	echo ">>> Backing up pakreqBot database and config...";
	COPY /var/pakreqBot/data/* $BACKUP_PATH/pakreqBot;

	# Puffer
	echo ">>> Backing up puffer files...";
	COPY /var/lib/pufferd/* $BACKUP_PATH/pufferd/;
	
	# Minio
	echo ">>> Backing up minio...";
	COPY /srv/minio $BACKUP_PATH/minio;

	# Docker containers
	if [ -d $BACKUP_PATH/docker ]; then
		rm -Rf $BACKUP_PATH/docker;
	fi
	mkdir -p $BACKUP_PATH/docker;
	for i in $(docker ps --format "{{.Names}}"); do
		echo ">>> Backing up docker container $i...";
		docker export  $i | xz -9 -c - > $BACKUP_PATH/docker/$i.tar.xz;
	done
}

function SYNC {
	/usr/bin/rclone purge $RCLONE_REMOTE;
	/usr/bin/rclone sync $BACKUP_PATH $RCLONE_REMOTE --copy-links;
}

function MAIN {
	BACKUP;
	# Sync backups
	echo ">>> Syncing backups...";
	SYNC;
	echo ">>> Done.";
}

MAIN;
