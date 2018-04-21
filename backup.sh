#!/bin/bash

SYNC_COMMAND="/usr/bin/rclone sync /opt/backup GDrive:/server-backup";

set -e;

# GitLab
/opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1;
cp -R /etc/gitlab /opt/backup/gitlab/config;

# Sync backups
$SYNC_COMMAND;
