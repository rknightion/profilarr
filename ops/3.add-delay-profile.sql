-- @operation: create
-- @entity: delay_profile
-- @name: Add default delay profile
insert into "delay_profiles" ("name", "preferred_protocol", "usenet_delay", "torrent_delay", "bypass_if_highest_quality", "bypass_if_above_custom_format_score", "minimum_custom_format_score") values ('Default', 'prefer_torrent', 600, 600, 0, 0, NULL);
