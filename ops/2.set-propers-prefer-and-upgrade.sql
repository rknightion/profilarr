-- @operation: update
-- @entity: media_settings
-- @name: Propers and Repacks - Prefer and Upgrade
update "radarr_media_settings" set "propers_repacks" = 'preferAndUpgrade' where "name" = 'default' and "propers_repacks" = 'doNotPrefer';
update "sonarr_media_settings" set "propers_repacks" = 'preferAndUpgrade' where "name" = 'default' and "propers_repacks" = 'doNotPrefer';
