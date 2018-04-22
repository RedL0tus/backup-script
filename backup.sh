#!/bin/bash

SYNC_COMMAND="/usr/bin/rclone sync /opt/backup GDrive:/server-backup";

set -e;

# GitLab
/opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1;
cp -R /etc/gitlab /opt/backup/gitlab/config;

# Mastodon
sudo -u postgres pg_dumpall | gzip /opt/backup/pg_dump.gz;
cp -R /home/mastodon/live /opt/backup/mastodon;

# Sync backups
$SYNC_COMMAND;
