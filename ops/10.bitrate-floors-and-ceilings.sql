-- @operation: update
-- @entity: batch
-- @name: Bitrate floors and ceilings for both arrs
--
-- Radarr 1080p: 18 / 55 / 90 MB/min = a 2.2 GB floor, ~6.5 GB target and a ~10.5 GB ceiling for a
-- 2-hour film. The old 2 MB/min floor allowed a 240 MB "film", and the old 60 MB/min ceiling was a
-- HARD REJECT that was discarding WiKi, UBits, HiDt, DarQ-HONE and YAWNTiC as oversized.
-- A flat floor is used rather than TRaSH's per-source table: their Bluray-1080p minimum of 50.8 is
-- calibrated for x264 and would silently reject the entire x265 Bluray tier.
--
-- Sonarr 1080p: 8 / 89 / 90 MB/min. Deliberately lower than Radarr's - Sonarr's table is GLOBAL
-- per instance, so it also governs the 49 monitored series at 25 minutes or shorter and the anime
-- titles. The tier scores and minimum_custom_format_score do the quality work, not the floor.
-- preferred 89 against max 90 knowingly accepts a Sonarr quirk: DownloadDecisionComparer.CompareSize
-- uses Series.Runtime (one episode) rather than the pack total, so on an exact tie between two
-- season packs the smaller wins. Accepted because CompareSize is the last comparison and
-- CompareEpisodeCount already prefers full seasons before it is reached.
--
-- 2160p preferred was 16, BELOW 1080p's 18. Corrected.

update "radarr_quality_definitions" set "min_size" = 18, "preferred_size" = 55, "max_size" = 90 where "name" = 'default' and "quality_name" = 'Bluray-1080p'  and "min_size" = 2 and "preferred_size" = 18 and "max_size" = 60;
update "radarr_quality_definitions" set "min_size" = 18, "preferred_size" = 55, "max_size" = 90 where "name" = 'default' and "quality_name" = 'WEBDL-1080p'   and "min_size" = 2 and "preferred_size" = 18 and "max_size" = 60;
update "radarr_quality_definitions" set "min_size" = 18, "preferred_size" = 55, "max_size" = 90 where "name" = 'default' and "quality_name" = 'WEBRip-1080p'  and "min_size" = 2 and "preferred_size" = 18 and "max_size" = 60;
update "radarr_quality_definitions" set "min_size" = 18, "preferred_size" = 55, "max_size" = 90 where "name" = 'default' and "quality_name" = 'HDTV-1080p'    and "min_size" = 2 and "preferred_size" = 18 and "max_size" = 60;
update "radarr_quality_definitions" set "min_size" = 25, "preferred_size" = 120, "max_size" = 200 where "name" = 'default' and "quality_name" = 'Bluray-2160p' and "min_size" = 4.5 and "preferred_size" = 16 and "max_size" = 180;
update "radarr_quality_definitions" set "min_size" = 25, "preferred_size" = 120, "max_size" = 200 where "name" = 'default' and "quality_name" = 'WEBDL-2160p'  and "min_size" = 4.5 and "preferred_size" = 16 and "max_size" = 180;
update "radarr_quality_definitions" set "min_size" = 25, "preferred_size" = 120, "max_size" = 200 where "name" = 'default' and "quality_name" = 'WEBRip-2160p' and "min_size" = 4.5 and "preferred_size" = 16 and "max_size" = 180;
update "radarr_quality_definitions" set "min_size" = 25, "preferred_size" = 120, "max_size" = 200 where "name" = 'default' and "quality_name" = 'HDTV-2160p'   and "min_size" = 4.5 and "preferred_size" = 18 and "max_size" = 180;
update "radarr_quality_definitions" set "min_size" = 60, "preferred_size" = 200, "max_size" = 400 where "name" = 'default' and "quality_name" = 'Remux-2160p'  and "min_size" = 4.5 and "preferred_size" = 16 and "max_size" = 180;

update "sonarr_quality_definitions" set "min_size" = 8, "preferred_size" = 89, "max_size" = 90 where "name" = 'default' and "quality_name" = 'Bluray-1080p'  and "min_size" = 2 and "preferred_size" = 18 and "max_size" = 60;
update "sonarr_quality_definitions" set "min_size" = 8, "preferred_size" = 89, "max_size" = 90 where "name" = 'default' and "quality_name" = 'WEBDL-1080p'   and "min_size" = 2 and "preferred_size" = 18 and "max_size" = 60;
update "sonarr_quality_definitions" set "min_size" = 8, "preferred_size" = 89, "max_size" = 90 where "name" = 'default' and "quality_name" = 'WEBRip-1080p'  and "min_size" = 2 and "preferred_size" = 18 and "max_size" = 60;
update "sonarr_quality_definitions" set "min_size" = 8, "preferred_size" = 89, "max_size" = 90 where "name" = 'default' and "quality_name" = 'HDTV-1080p'    and "min_size" = 2 and "preferred_size" = 18 and "max_size" = 60;
update "sonarr_quality_definitions" set "min_size" = 20, "preferred_size" = 150, "max_size" = 200 where "name" = 'default' and "quality_name" = 'Bluray-2160p' and "min_size" = 4.5 and "preferred_size" = 16 and "max_size" = 180;
update "sonarr_quality_definitions" set "min_size" = 20, "preferred_size" = 150, "max_size" = 200 where "name" = 'default' and "quality_name" = 'WEBDL-2160p'  and "min_size" = 4.5 and "preferred_size" = 16 and "max_size" = 180;
update "sonarr_quality_definitions" set "min_size" = 20, "preferred_size" = 150, "max_size" = 200 where "name" = 'default' and "quality_name" = 'WEBRip-2160p' and "min_size" = 4.5 and "preferred_size" = 16 and "max_size" = 180;
update "sonarr_quality_definitions" set "min_size" = 20, "preferred_size" = 150, "max_size" = 200 where "name" = 'default' and "quality_name" = 'HDTV-2160p'   and "min_size" = 4.5 and "preferred_size" = 18 and "max_size" = 180;
