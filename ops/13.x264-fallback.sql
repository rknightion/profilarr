-- @operation: update
-- @entity: batch
-- @name: Allow x264 as a gated fallback where no acceptable x265 exists
--
-- Measured 2026-09-20: of ten proving-run films, three had zero acceptable releases purely
-- because x264 was a hard -10000 block. Two of those (Voicemails for Isabelle, Trap House) had
-- 5.0 GB NF/AMZN WEB-DL x264 releases from HONE, FLUX, Kitsune and playWEB sitting unusable.
--
-- The gate is arithmetic, not a second group list. x264 carries a flat -1200 and keeps the
-- existing -200 'No x265 Detected', so a release needs a tier bonus of 400 or more (tiers 1-5)
-- to clear the profile's -1000 minimum. Tier 6, tier 7 and unlisted groups stay rejected. This
-- deliberately reuses the tier ladder as the whitelist so the two cannot drift apart.
--
-- Worked scores in 1080p x265 Compact, from the live 2026-09-20 release data:
--   HONE     1080p NF WEB-DL 5.01 GB   1 + 100 + 600 - 200 - 1200 = -699   accepted
--   FLUX     1080p NF WEB-DL 5.01 GB   1 + 125 + 500 - 200 - 1200 = -774   accepted
--   GeneMige 1080p WebDL     5.26 GB   1 +   0 + 500 - 200 - 1200 = -899   accepted
--   BiO      1080p NF WEB-DL 5.69 GB   1 + 125 +   0 - 200 - 1200 = -1274  rejected
--   UKDHD    1080p WEB       5.96 GB   1 +   0 +   0 - 200 - 1200 = -1399  rejected
--
-- The worst acceptable x265 (tier 7, x265 HEVC, 1080p) scores +201 and the best reachable x264
-- is about -449, so no x264 can ever out-score any x265. UpgradableSpecification compares
-- custom-format score alone once quality rank ties, and all 1080p qualities are merged into the
-- Good 1080p group, so an x265 always upgrades over an x264 and never the reverse.
--
-- Bluray remuxes and Bluray/WEBRip re-encodes are excluded by source and by a 10 GiB ceiling.
-- x264 stays a hard block on the 4K and TV profiles.

-- ------------------------------------------------- stop Unwanted Codecs BLOCK from catching x264

DELETE FROM condition_patterns
 WHERE custom_format_name = 'Unwanted Codecs BLOCK' AND condition_name = 'x264 AVC';
DELETE FROM custom_format_conditions
 WHERE custom_format_name = 'Unwanted Codecs BLOCK' AND name = 'x264 AVC';

UPDATE custom_formats
   SET description = 'Blocks unwanted codecs - AV1, XviD, DivX, MPEG-2, VC-1, WMV. x264 is scored separately by x264 Codec.'
 WHERE name = 'Unwanted Codecs BLOCK'
   AND description = 'Blocks unwanted codecs - x264, AV1, XviD, DivX, MPEG-2, VC-1, WMV';

-- ------------------------------------------------- custom formats

INSERT INTO custom_formats (name, description) VALUES
 ('x264 Codec', 'Release is x264/AVC. Flat penalty so only tier 1-5 groups clear the profile minimum.'),
 ('x264 Bad Source or Oversize', 'x264 from a source below WEB-DL/Bluray, or larger than 10 GiB');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required) VALUES
 ('x264 Codec',                  'x264 AVC',    'release_title', 'all', 0, 1),
 ('x264 Bad Source or Oversize', 'x264 AVC',    'release_title', 'all', 0, 1),
 ('x264 Bad Source or Oversize', 'Unknown',     'source',        'all', 0, 0),
 ('x264 Bad Source or Oversize', 'Television',  'source',        'all', 0, 0),
 ('x264 Bad Source or Oversize', 'WEBRip',      'source',        'all', 0, 0),
 ('x264 Bad Source or Oversize', 'DVD',         'source',        'all', 0, 0),
 ('x264 Bad Source or Oversize', 'CAM',         'source',        'all', 0, 0),
 ('x264 Bad Source or Oversize', 'Telesync',    'source',        'all', 0, 0),
 ('x264 Bad Source or Oversize', 'Telecine',    'source',        'all', 0, 0),
 ('x264 Bad Source or Oversize', 'Workprint',   'source',        'all', 0, 0),
 ('x264 Bad Source or Oversize', 'Over 10 GiB', 'size',          'all', 0, 0);

INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name) VALUES
 ('x264 Codec',                  'x264 AVC', 'x264 AVC'),
 ('x264 Bad Source or Oversize', 'x264 AVC', 'x264 AVC');

-- web_dl and bluray are deliberately absent: they are the two permitted sources. A Bluray x264
-- encode from a tier 1-5 group is wanted; a Bluray remux is caught by the 10 GiB ceiling below.
INSERT INTO condition_sources (custom_format_name, condition_name, source) VALUES
 ('x264 Bad Source or Oversize', 'Unknown',    'unknown'),
 ('x264 Bad Source or Oversize', 'Television', 'television'),
 ('x264 Bad Source or Oversize', 'WEBRip',     'webrip'),
 ('x264 Bad Source or Oversize', 'DVD',        'dvd'),
 ('x264 Bad Source or Oversize', 'CAM',        'cam'),
 ('x264 Bad Source or Oversize', 'Telesync',   'telesync'),
 ('x264 Bad Source or Oversize', 'Telecine',   'telecine'),
 ('x264 Bad Source or Oversize', 'Workprint',  'workprint');

-- Radarr's SizeSpecification is `size > min && size <= max`, so a release of exactly 10 GiB is
-- not oversize. The upper bound is explicit because Profilarr renders a NULL bound as 0 GB,
-- which would match nothing.
INSERT INTO condition_sizes (custom_format_name, condition_name, min_bytes, max_bytes) VALUES
 ('x264 Bad Source or Oversize', 'Over 10 GiB', 10737418240, 10737418240000);

-- ------------------------------------------------- profile scores

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('1080p x265 Compact', 'x264 Codec',                  'all',  -1200),
 ('1080p x265 Compact', 'x264 Bad Source or Oversize', 'all', -10000),
 ('4K x265 DV HDR',     'x264 Codec',                  'all', -10000),
 ('4K x265 DV HDR',     'x264 Bad Source or Oversize', 'all',      0),
 ('1080p x265 TV',      'x264 Codec',                  'all', -10000),
 ('1080p x265 TV',      'x264 Bad Source or Oversize', 'all',      0);
