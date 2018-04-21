#!/bin/bash

set -e;

# GitLab
/opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1;
cp -R /etc/gitlab /opt/backup/gitlab/config;
