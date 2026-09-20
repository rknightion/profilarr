-- @operation: update
-- @entity: batch
-- @name: Gate x264 by group explicitly so it can rank above the compact re-encoders
--
-- Op 13 used the -1000 profile minimum as the whitelist: x264 carried a flat -1200 so only a
-- release with a tier bonus of 400 or more cleared the floor. That worked, but it forced every
-- x264 into the -699..-999 band, which is BELOW the compact re-encoders (Compact Re-encode -800
-- plus x265 100 gives NeoNoir about -624). Measured live on 2026-09-20: Voicemails for Isabelle
-- and Trap House both hold a 1.3 GB NeoNoir x265 WEBRip at -624, and the 5.01 GB NF WEB-DL x264
-- from HONE at -699 was refused as "Existing file on disk has a equal or higher Custom Format
-- score". A 1.3 GB WEBRip beating a 5 GB WEB-DL is the exact failure this redesign exists to fix.
--
-- Gating and ranking are now two mechanisms. x264 is whitelisted by an explicit negated group
-- condition, which frees the flat penalty to be a ranking term instead of a floor trick.
--
-- The whitelist is tiers 1 and 3 only - the WEB-DL and Bluray SOURCE groups. Tiers 2, 4 and 5 are
-- x265 re-encoders; an x264 "re-encode" from one of them is a decade-old artefact, not a fallback.
-- So the rule is: x264 is accepted only as an original WEB-DL or Bluray from a trusted source
-- group, never as a re-encode. This list must be kept in step with x265 Tier 1 Groups and
-- x265 Tier 3 Groups by hand; the regexes cannot reference each other.
--
-- Resulting film scores, from the live release data:
--   HONE     1080p NF WEB-DL   -600 + 600 + 101 - 200 =  -99
--   FLUX     1080p NF WEB-DL   -600 + 500 + 126 - 200 = -174
--   FLUX     1080p AMZN WEB-DL -600 + 500 +  26 - 200 = -274
--   GeneMige 1080p WebDL       -600 + 500 +   1 - 200 = -299
--   NeoNoir  1080p x265 WEBRip                          -624   now beaten
--   d3g      1080p x265                                 -699   now beaten
--   any untrusted-group x264                          -10000   rejected
--
-- The worst acceptable x265 is still +201 (tier 7 plus x265 HEVC plus 1080p), so no x264 can
-- out-score any x265 and the one-way upgrade guarantee is unchanged.

INSERT INTO regular_expressions (name, pattern, description) VALUES
 ('x264 Trusted Source Groups',
  '^(HONE|BYNDR|CMRG|FLUX|HHWEB|Kitsune|MZABI|NTb|SMURF|TEPES|playWEB|WiKi|HiDt|UBits|YAWNTiC|GeneMige|BRUTE|SPHD|j3rico)$',
  'Union of x265 Tier 1 and Tier 3 - the WEB-DL and Bluray source groups. Keep in step with those two by hand.');

INSERT INTO custom_formats (name, description) VALUES
 ('x264 Untrusted Group', 'x264 from a group outside the trusted WEB-DL/Bluray source list');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required) VALUES
 ('x264 Untrusted Group', 'x264 AVC',      'release_title', 'all', 0, 1),
 ('x264 Untrusted Group', 'Not Trusted',   'release_group', 'all', 1, 1);

INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name) VALUES
 ('x264 Untrusted Group', 'x264 AVC',    'x264 AVC'),
 ('x264 Untrusted Group', 'Not Trusted', 'x264 Trusted Source Groups');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('1080p x265 Compact', 'x264 Untrusted Group', 'all', -10000),
 ('4K x265 DV HDR',     'x264 Untrusted Group', 'all', -10000),
 ('1080p x265 TV',      'x264 Untrusted Group', 'all', -10000);

-- The flat penalty is now a ranking term, not the whitelist. Written as a delete-then-insert
-- rather than a pinned UPDATE: a guarded UPDATE that matches nothing completes silently and
-- would leave x264 at op 13's -1200 while looking applied. Same rationale as op 8.
DELETE FROM quality_profile_custom_formats
 WHERE quality_profile_name = '1080p x265 Compact'
   AND custom_format_name = 'x264 Codec';

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('1080p x265 Compact', 'x264 Codec', 'all', -600);
