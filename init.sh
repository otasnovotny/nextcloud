git clone git@github.com:otasnovotny/nextcloud.git
cd nextcloud

# -- Remove errors and warnings listed in administration settings --
docker compose exec -it --user www-data nextcloud bash

# Solving error about cron failed
php occ files:scan --all
php -f ./cron.php

# remove error (extra file)
sudo rm ~/html/nextcloud-init-sync.lock

# set default region
docker exec --user www-data nextcloud-app-1 php occ config:system:set default_phone_region --value="CZ"
# OR
docker compose exec -it --user www-data app php occ config:system:set default_phone_region --value="CZ"

# Server has no maintenance window start time configured. This means resource intensive daily background jobs will also
# be executed during your main usage time. We recommend to set it to a time of low usage, so users are less impacted by
# the load caused from these heavy tasks. For more details see the documentation
docker exec --user www-data nextcloud-app-1 php occ config:system:set maintenance_window_start --type=integer --value=1

# One or more mimetype migrations are available. Occasionally new mimetypes are added to better handle certain file
# types. Migrating the mimetypes take a long time on larger instances so this is not done automatically during upgrades.
# Use the command `occ maintenance:repair --include-expensive` to perform the migrations.
docker exec --user www-data nextcloud-app-1 php occ maintenance:repair --include-expensive

# Some headers are not set correctly on your instance - The `Strict-Transport-Security` HTTP header is not set (should
# be at least `15552000` seconds). For enhanced security, it is recommended to enable HSTS. For more details see the
# documentation ↗.
# - settings on traefik
# - try on https://securityheaders.com/

# Detected some missing optional indices. Occasionally new indices are added (by Nextcloud or installed applications)
# to improve database performance. Adding indices can sometimes take awhile and temporarily hurt performance so this is
# not done automatically during upgrades. Once the indices are added, queries to those tables should be faster.
# Use the command `occ db:add-missing-indices` to add them. Missing indices: "systag_by_objectid" in table
# "systemtag_object_mapping". For more details see the documentation ↗.
docker compose exec -it --user www-data app php occ db:add-missing-indices

# Logs in https://nextcloud.otasovo.cz/settings/admin/logging
docker compose exec -it --user www-data app rm ./data/nextcloud.log

# Warnings and errors in log
# - Remove / Disable apps: UsageSurvey, Whiteboard
