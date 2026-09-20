-- @operation: update
-- @entity: batch
-- @name: English audio required, drop Unknown and HDTV, lower the minimum format score
--
-- Language: 'Original' does not require an English track, it just accepts each title in its own
-- original language. The requirement is that an English audio track be PRESENT (a dub or an
-- English track); subtitles alone are not sufficient. Radarr/Sonarr's own language filter set to
-- English enforces exactly that, which is why the 'Language Not English' custom format was
-- retired in op 7 and 'Dubbed Audio Title' drops from -10000 to -100 in op 8: MULTi and Dual
-- Audio are how a foreign release signals it carries an English track.
--
-- IMPORTANT: Sonarr v4 quality profiles have NO language field - only Radarr's do (verified
-- against both live APIs: Radarr's profile JSON carries "language", Sonarr's does not). So the
-- profile-language change below reaches Radarr only, and Sonarr needs a custom format instead.
-- 'Not English Audio' below is that format, scored -10000 on the Sonarr side and 0 on Radarr,
-- where the profile language already enforces it. Radarr must NOT get both, or foreign-language
-- films become un-grabbable again.
--
-- The condition matches releases whose parsed languages do NOT include English, so a MULTi or
-- Dual Audio release of a foreign title still passes - which is the actual requirement: an
-- English audio track must be present, subtitles alone are not sufficient.
--
-- minimum_custom_format_score -1000 is what makes graceful degradation work. A banned group
-- scores about -9900 net and is rejected outright; a merely compact group scores about -700 and
-- is still grabbable as a last resort, then upgraded later on score.

DELETE FROM quality_profile_languages
 WHERE quality_profile_name IN ('1080p x265 Compact', '4K x265 DV HDR');

INSERT INTO quality_profile_languages (quality_profile_name, language_name, type) VALUES
 ('1080p x265 Compact', 'English', 'simple'),
 ('4K x265 DV HDR',     'English', 'simple');

update "quality_profiles" set "minimum_custom_format_score" = -1000 where "name" = '1080p x265 Compact' and "minimum_custom_format_score" = 10;
update "quality_profiles" set "minimum_custom_format_score" = -1000 where "name" = '4K x265 DV HDR' and "minimum_custom_format_score" = 10;

-- Unknown accepts anything the parser cannot read; HDTV-1080p is below the WEB/Bluray floor.
update "quality_profile_qualities" set "enabled" = 0 where "quality_profile_name" = '1080p x265 Compact' and "quality_name" = 'Unknown' and "enabled" = 1;
update "quality_profile_qualities" set "enabled" = 0 where "quality_profile_name" = '1080p x265 Compact' and "quality_name" = 'HDTV-1080p' and "enabled" = 1;
update "quality_profile_qualities" set "enabled" = 0 where "quality_profile_name" = '4K x265 DV HDR' and "quality_name" = 'HDTV-2160p' and "enabled" = 1;

-- ---------------------------------------------------------------- Sonarr language enforcement

INSERT INTO custom_formats (name, description) VALUES
 ('Not English Audio', 'Release has no English audio track - Sonarr only, Radarr uses the profile language');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required) VALUES
 ('Not English Audio', 'Not English', 'language', 'all', 1, 1);

INSERT INTO condition_languages (custom_format_name, condition_name, language_name, except_language) VALUES
 ('Not English Audio', 'Not English', 'English', 0);

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('1080p x265 Compact', 'Not English Audio', 'sonarr', -10000),
 ('1080p x265 Compact', 'Not English Audio', 'radarr',      0),
 ('4K x265 DV HDR',     'Not English Audio', 'sonarr', -10000),
 ('4K x265 DV HDR',     'Not English Audio', 'radarr',      0);
