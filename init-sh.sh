git clone git@github.com:otasnovotny/nextcloud.git

# -----------------
# OCC console - get into nextcloud-app-1 container:
docker exec -it --user www-data nextcloud-app-1 bash

# then
# Solving error about cron failed
php occ config:system:set default_phone_region --value="CZ"
php occ files:scan --all
php -f ./cron.php

# remove error (extra file)
sudo rm ~/html/nextcloud-init-sync.lock

# -----------------
# OR from Host machine directly to container, like:
docker exec --user www-data nextcloud-app-1 php occ config:system:set default_phone_region --value="CZ"
