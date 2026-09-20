-- @operation: update
-- @entity: quality_profile_custom_formats
-- @name: Rescore both profiles onto the tier ladder, with per-arr divergence
--
-- Full replace rather than guarded per-row updates: the previous score set is being retired
-- wholesale and a partial application would be worse than none.
--
-- Scores that are identical in both arrs use arr_type 'all'. Scores that differ use a radarr
-- row and a sonarr row and NO 'all' row, matching the existing convention for
-- 'DV No Fallback P5 AVOID'.
--
-- Rationale for the divergences:
--   iVy              banned for film by TRaSH and Dictionarry; Dictionarry tiers it for TV.
--   d3g              banned by both, but measured 41.1 MB/min on TV here vs 24 on film.
--   MeGusta / PSA    ~1900 kbps, roughly 30% of HONE; Dictionarry allows them on HEVC TV profiles.
--   Tier 6 / House   TV-measured groups rank higher on the TV side.
--   Compact          softer on TV, where the supply of good x265 is thinner.

DELETE FROM quality_profile_custom_formats
 WHERE quality_profile_name IN ('1080p x265 Compact', '4K x265 DV HDR');

-- ---------------------------------------------------------------- 1080p x265 Compact, shared

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('1080p x265 Compact', 'x265 Tier 4',              'all',    450),
 ('1080p x265 Compact', 'Banned Groups',            'all', -10000),
 ('1080p x265 Compact', 'Banned Dual Audio Groups', 'all', -10000),
 ('1080p x265 Compact', 'Unwanted Codecs BLOCK',    'all', -10000),
 ('1080p x265 Compact', 'LQ Release Title',         'all', -10000),
 ('1080p x265 Compact', 'Line Mic Dubbed',          'all', -10000),
 ('1080p x265 Compact', '4k',                       'all', -10000),
 ('1080p x265 Compact', 'SM737 Fake DV',            'all',   -400),
 ('1080p x265 Compact', 'DTS All AVOID',            'all',   -300),
 ('1080p x265 Compact', 'No x265 Detected',         'all',   -200),
 ('1080p x265 Compact', 'Dubbed Audio Title',       'all',   -100),
 ('1080p x265 Compact', 'TrueHD Atmos AVOID',       'all',    -30),
 ('1080p x265 Compact', 'Lossless Audio AVOID',     'all',    -30),
 ('1080p x265 Compact', 'x265 HEVC',                'all',    100),
 ('1080p x265 Compact', 'DV HDR10 Compatible',      'all',    100),
 ('1080p x265 Compact', 'DD+ Atmos',                'all',    100),
 ('1080p x265 Compact', '10-bit',                   'all',     50),
 ('1080p x265 Compact', 'HDR10Plus',                'all',     50),
 ('1080p x265 Compact', 'PROPER REPACK',            'all',     25),
 ('1080p x265 Compact', 'DDP 5.1',                  'all',     25),
 ('1080p x265 Compact', 'HDR10',                    'all',     15),
 ('1080p x265 Compact', '5.1 Surround',             'all',     10),
 ('1080p x265 Compact', '1080p',                    'all',      1);

-- ---------------------------------------------------------------- 1080p x265 Compact, per arr

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('1080p x265 Compact', 'x265 Tier 1',             'radarr',    600),
 ('1080p x265 Compact', 'x265 Tier 1',             'sonarr',    520),
 ('1080p x265 Compact', 'x265 Tier 2',             'radarr',    550),
 ('1080p x265 Compact', 'x265 Tier 2',             'sonarr',    500),
 ('1080p x265 Compact', 'x265 Tier 3',             'radarr',    500),
 ('1080p x265 Compact', 'x265 Tier 3',             'sonarr',    470),
 ('1080p x265 Compact', 'x265 Tier 5',             'radarr',    400),
 ('1080p x265 Compact', 'x265 Tier 5',             'sonarr',    380),
 ('1080p x265 Compact', 'x265 Tier 6',             'radarr',    200),
 ('1080p x265 Compact', 'x265 Tier 6',             'sonarr',    300),
 ('1080p x265 Compact', 'House TV Tier',           'radarr',    200),
 ('1080p x265 Compact', 'House TV Tier',           'sonarr',    300),
 ('1080p x265 Compact', 'x265 Tier 7',             'radarr',    100),
 ('1080p x265 Compact', 'x265 Tier 7',             'sonarr',    150),
 ('1080p x265 Compact', 'Group iVy',               'radarr', -10000),
 ('1080p x265 Compact', 'Group iVy',               'sonarr',    150),
 ('1080p x265 Compact', 'Group d3g',               'radarr',   -800),
 ('1080p x265 Compact', 'Group d3g',               'sonarr',    100),
 ('1080p x265 Compact', 'Group MeGusta PSA',       'radarr', -10000),
 ('1080p x265 Compact', 'Group MeGusta PSA',       'sonarr',      0),
 ('1080p x265 Compact', 'Compact Re-encode',       'radarr',   -800),
 ('1080p x265 Compact', 'Compact Re-encode',       'sonarr',   -400),
 ('1080p x265 Compact', 'DV No Fallback P5 AVOID', 'radarr',   -300),
 ('1080p x265 Compact', 'DV No Fallback P5 AVOID', 'sonarr',   -200);

-- ---------------------------------------------------------------- 4K x265 DV HDR, shared
-- Keeps the profile's stronger HDR/DV emphasis; same tier ladder and same audio policy.

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('4K x265 DV HDR', 'x265 Tier 4',              'all',    450),
 ('4K x265 DV HDR', 'Banned Groups',            'all', -10000),
 ('4K x265 DV HDR', 'Banned Dual Audio Groups', 'all', -10000),
 ('4K x265 DV HDR', 'Unwanted Codecs BLOCK',    'all', -10000),
 ('4K x265 DV HDR', 'LQ Release Title',         'all', -10000),
 ('4K x265 DV HDR', 'Line Mic Dubbed',          'all', -10000),
 ('4K x265 DV HDR', '1080p',                    'all', -10000),
 ('4K x265 DV HDR', 'SM737 Fake DV',            'all',   -400),
 ('4K x265 DV HDR', 'DTS All AVOID',            'all',   -300),
 ('4K x265 DV HDR', 'No x265 Detected',         'all',   -200),
 ('4K x265 DV HDR', 'Dubbed Audio Title',       'all',   -100),
 ('4K x265 DV HDR', 'TrueHD Atmos AVOID',       'all',    -30),
 ('4K x265 DV HDR', 'Lossless Audio AVOID',     'all',    -30),
 ('4K x265 DV HDR', 'DV HDR10 Compatible',      'all',    200),
 ('4K x265 DV HDR', 'x265 HEVC',                'all',    150),
 ('4K x265 DV HDR', 'HDR10Plus',                'all',    100),
 ('4K x265 DV HDR', 'HDR10',                    'all',    100),
 ('4K x265 DV HDR', 'DD+ Atmos',                'all',    100),
 ('4K x265 DV HDR', '10-bit',                   'all',     25),
 ('4K x265 DV HDR', 'PROPER REPACK',            'all',     25),
 ('4K x265 DV HDR', 'DDP 5.1',                  'all',     25),
 ('4K x265 DV HDR', '5.1 Surround',             'all',     10),
 ('4K x265 DV HDR', '4k',                       'all',      1);

-- ---------------------------------------------------------------- 4K x265 DV HDR, per arr

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('4K x265 DV HDR', 'x265 Tier 1',             'radarr',    600),
 ('4K x265 DV HDR', 'x265 Tier 1',             'sonarr',    520),
 ('4K x265 DV HDR', 'x265 Tier 2',             'radarr',    550),
 ('4K x265 DV HDR', 'x265 Tier 2',             'sonarr',    500),
 ('4K x265 DV HDR', 'x265 Tier 3',             'radarr',    500),
 ('4K x265 DV HDR', 'x265 Tier 3',             'sonarr',    470),
 ('4K x265 DV HDR', 'x265 Tier 5',             'radarr',    400),
 ('4K x265 DV HDR', 'x265 Tier 5',             'sonarr',    380),
 ('4K x265 DV HDR', 'x265 Tier 6',             'radarr',    200),
 ('4K x265 DV HDR', 'x265 Tier 6',             'sonarr',    300),
 ('4K x265 DV HDR', 'House TV Tier',           'radarr',    200),
 ('4K x265 DV HDR', 'House TV Tier',           'sonarr',    300),
 ('4K x265 DV HDR', 'x265 Tier 7',             'radarr',    100),
 ('4K x265 DV HDR', 'x265 Tier 7',             'sonarr',    150),
 ('4K x265 DV HDR', 'Group iVy',               'radarr', -10000),
 ('4K x265 DV HDR', 'Group iVy',               'sonarr',    150),
 ('4K x265 DV HDR', 'Group d3g',               'radarr',   -800),
 ('4K x265 DV HDR', 'Group d3g',               'sonarr',    100),
 ('4K x265 DV HDR', 'Group MeGusta PSA',       'radarr', -10000),
 ('4K x265 DV HDR', 'Group MeGusta PSA',       'sonarr',      0),
 ('4K x265 DV HDR', 'Compact Re-encode',       'radarr',   -800),
 ('4K x265 DV HDR', 'Compact Re-encode',       'sonarr',   -400),
 ('4K x265 DV HDR', 'DV No Fallback P5 AVOID', 'radarr',   -300),
 ('4K x265 DV HDR', 'DV No Fallback P5 AVOID', 'sonarr',   -200);
