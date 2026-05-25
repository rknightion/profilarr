-- @operation: export
-- @entity: batch
-- @name: dfs
-- @exportedAt: 2026-05-25T17:12:12.454Z
-- @opIds: 166, 167

-- --- BEGIN op 166 ( update delay_profile "Default" )
update "delay_profiles" set "torrent_delay" = 10 where "name" = 'Default' and "torrent_delay" = 600;
-- --- END op 166

-- --- BEGIN op 167 ( update delay_profile "Default" )
update "delay_profiles" set "bypass_if_highest_quality" = 1 where "name" = 'Default' and "bypass_if_highest_quality" = 0;
-- --- END op 167
