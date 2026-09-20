-- @operation: create
-- @entity: quality_profile
-- @name: Add a TV-specific profile so the upgrade ceiling can differ from film
--
-- quality_profiles.upgrade_until_score has no arr_type, so Radarr and Sonarr cannot have different
-- upgrade ceilings while sharing one profile. Film needs a high ceiling (900) to keep files
-- upgradeable through the phased backfill; TV needs a low one (400) so an episode is not silently
-- replaced weeks after it was watched. Hence a separate TV profile.
--
-- Scores are the Sonarr column from op 8, written as arr_type 'all' because only Sonarr syncs this
-- profile. Membership is currently identical to the film ladder; keeping it separate means TV tier
-- membership can diverge later, which the research says it should - Dictionarry's TV tiers are a
-- genuinely different group set from its movie tiers.

INSERT INTO quality_profiles (name, description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment)
VALUES ('1080p x265 TV', 'x265 TV, tiered release groups, low upgrade ceiling so watched episodes are not replaced', 1, -1000, 400, 50);

INSERT INTO quality_groups (quality_profile_name, name) VALUES ('1080p x265 TV', 'Good 1080p');

INSERT INTO quality_group_members (quality_profile_name, quality_group_name, quality_name, position) VALUES
 ('1080p x265 TV', 'Good 1080p', 'Bluray-1080p', 0),
 ('1080p x265 TV', 'Good 1080p', 'WEBDL-1080p',  0),
 ('1080p x265 TV', 'Good 1080p', 'WEBRip-1080p', 0);

INSERT INTO quality_profile_qualities (quality_profile_name, quality_name, quality_group_name, position, enabled, upgrade_until) VALUES
 ('1080p x265 TV', NULL,         'Good 1080p', 0, 1, 1),
 ('1080p x265 TV', 'HDTV-1080p', NULL,         1, 0, 0),
 ('1080p x265 TV', 'Unknown',    NULL,         2, 0, 0);

INSERT INTO quality_profile_languages (quality_profile_name, language_name, type) VALUES
 ('1080p x265 TV', 'English', 'simple');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('1080p x265 TV', 'x265 Tier 1',                'all',    520),
 ('1080p x265 TV', 'x265 Tier 2',                'all',    500),
 ('1080p x265 TV', 'x265 Tier 3',                'all',    470),
 ('1080p x265 TV', 'x265 Tier 4',                'all',    450),
 ('1080p x265 TV', 'x265 Tier 5',                'all',    380),
 ('1080p x265 TV', 'x265 Tier 6',                'all',    300),
 ('1080p x265 TV', 'House TV Tier',              'all',    300),
 ('1080p x265 TV', 'x265 Tier 7',                'all',    150),
 ('1080p x265 TV', 'Group iVy',                  'all',    150),
 ('1080p x265 TV', 'Group d3g',                  'all',    100),
 ('1080p x265 TV', 'Group MeGusta PSA',          'all',      0),
 ('1080p x265 TV', 'Compact Re-encode',          'all',   -400),
 ('1080p x265 TV', 'Banned Groups',              'all', -10000),
 ('1080p x265 TV', 'Banned Dual Audio Groups',   'all', -10000),
 ('1080p x265 TV', 'Unwanted Codecs BLOCK',      'all', -10000),
 ('1080p x265 TV', 'LQ Release Title',           'all', -10000),
 ('1080p x265 TV', 'Line Mic Dubbed',            'all', -10000),
 ('1080p x265 TV', '4k',                         'all', -10000),
 ('1080p x265 TV', 'SM737 Fake DV',              'all',   -400),
 ('1080p x265 TV', 'DTS All AVOID',              'all',   -300),
 ('1080p x265 TV', 'DV No Fallback P5 AVOID',    'all',   -200),
 ('1080p x265 TV', 'No x265 Detected',           'all',   -200),
 ('1080p x265 TV', 'Dubbed Audio Title',         'all',   -100),
 ('1080p x265 TV', 'TrueHD Atmos AVOID',         'all',    -30),
 ('1080p x265 TV', 'Lossless Audio AVOID',       'all',    -30),
 ('1080p x265 TV', 'x265 HEVC',                  'all',    100),
 ('1080p x265 TV', 'DV HDR10 Compatible',        'all',    100),
 ('1080p x265 TV', 'DD+ Atmos',                  'all',    100),
 ('1080p x265 TV', '10-bit',                     'all',     50),
 ('1080p x265 TV', 'HDR10Plus',                  'all',     50),
 ('1080p x265 TV', 'PROPER REPACK',              'all',     25),
 ('1080p x265 TV', 'DDP 5.1',                    'all',     25),
 ('1080p x265 TV', 'HDR10',                      'all',     15),
 ('1080p x265 TV', '5.1 Surround',               'all',     10),
 ('1080p x265 TV', '1080p',                      'all',      1),
 ('1080p x265 TV', 'Not English Audio',           'all', -10000);

-- Film upgrade ceilings.
update "quality_profiles" set "upgrade_until_score" = 900 where "name" = '1080p x265 Compact' and "upgrade_until_score" = 300;
update "quality_profiles" set "upgrade_until_score" = 900 where "name" = '4K x265 DV HDR' and "upgrade_until_score" = 400;
