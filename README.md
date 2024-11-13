# Nextcloud

This is a guide how to run [Nextcloud](https://nextcloud.com/) behind [Traefik](https://traefik.io/traefik/).

If you don't know how to setup Traefik, check out my example of 
[Traefik setup](https://github.com/otasnovotny/traefik).

Doc: https://docs.nextcloud.com/server/latest/admin_manual/installation/index.html

## Server

Clone repo and navigate to it
```
git clone git@github.com:otasnovotny/nextcloud.git && \
cd ./nextcloud
```

Create .env
```
# with proper values!!!
cp .env.template .env
```

Run service
```
docker compose up -d
```

## Admin settings

Login as admin from your `.env`

Navigate to `https://nextcloud.example.com/settings/admin/overview`.
There is a couple of warnings which need to be solved:

- _Server has no maintenance window start time configured. This means resource intensive daily background jobs will also
be executed during your main usage time. We recommend to set it to a time of low usage, so users are less impacted by
the load caused from these heavy tasks. For more details see the documentation_
```
docker compose exec --user www-data -it app php occ config:system:set maintenance_window_start --type=integer --value=1
```

- _One or more mimetype migrations are available. Occasionally new mimetypes are added to better handle certain file types. 
Migrating the mimetypes take a long time on larger instances so this is not done automatically during upgrades. 
Use the command `occ maintenance:repair --include-expensive` to perform the migrations._
```
docker compose exec --user www-data -it app php occ maintenance:repair --include-expensive
```

- _Some headers are not set correctly on your instance - The `Strict-Transport-Security` HTTP header is not set 
(should be at least `15552000` seconds). For enhanced security, it is recommended to enable HSTS. For more details 
see the [documentation](https://docs.nextcloud.com/server/30/admin_manual/installation/harden_server.html)._

**Solving**: See traefik labels for `app` container in `compose.yml`


- _Detected some missing optional indices. Occasionally new indices are added (by Nextcloud or installed applications)
to improve database performance. Adding indices can sometimes take awhile and temporarily hurt performance so this 
is not done automatically during upgrades. Once the indices are added, queries to those tables should be faster. 
Use the command `occ db:add-missing-indices` to add them. Missing indices: "systag_by_objectid" in table 
"systemtag_object_mapping". For more details see the 
[documentation ↗](https://docs.nextcloud.com/server/30/admin_manual/maintenance/upgrade.html#long-running-migration-steps)
._
```
docker compose exec -it --user www-data app php occ db:add-missing-indices
```

- _Your installation has no default phone region set. This is required to validate phone numbers in the profile settings 
without a country code. To allow numbers without a country code, please add "default_phone_region" with the respective 
ISO 3166-1 code of the region to your config file. For more details see the 
[documentation  ↗](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements)._
```
docker compose exec -it --user www-data app php occ config:system:set default_phone_region --value="CZ"
```

- _You have not set or verified your email server configuration, yet. Please head over to the "Basic settings" in order 
to set them. Afterwards, use the "Send email" button below the form to verify your settings. 
For more details see the 
[documentation ↗](https://docs.nextcloud.com/server/30/admin_manual/configuration_server/email_configuration.html)._
    
**Solving**: Go to to your Admin settings and set nextcloud email account. You can use [Mailcow](https://mailcow.email/)
behind [Traefik](https://doc.traefik.io/traefik/) 
described in [this guide](https://github.com/otasnovotny/mailcow-override), create a new account `nextcloud@example.com`
and set Email server with these settings:
```
Send mode: SMTP
Encryption: None/STARTTLS
From address: nextcloud@example.com
Server address: mail.example.com
Port: <empty>
Authentication: required
Credentials: nextcloud@example.com / your-awesome-password
```
Click `Send email` to check if your settings work.

- There are some warnings regarding your setup.
 ```
# delete log after fixing issues
docker compose exec -it --user www-data app rm ./data/nextcloud.log
```

Go to https://scan.nextcloud.com/ and check your nextcloud instance https://nextcloud.example.com.

## Client

### Desktop
Install [Nextcloud client](https://nextcloud.com/install/#install-clients) to sync files.

Your contacts and calendar url: https://nextcloud.example.com/remote.php/dav/ 

### Mobile device
Enable `Calendar app` and `Contacts app` in your Nextcloud https://nextcloud.example.com/settings/apps/enabled.

Install [Davx5](https://www.davx5.com/) to sync Calendar and Contacts on your mobile dievice.
