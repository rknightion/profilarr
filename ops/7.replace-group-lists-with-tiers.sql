-- @operation: update
-- @entity: batch
-- @name: Replace legacy group lists with tiered x265 release groups
--
-- The previous Trusted/LQ/Bad-Dual lists were an unmaintained Radarr v2/v3-era community set.
-- Four "trusted" groups (AOC, iVy, LAMA, PSA) are banned by both TRaSH and Dictionarry, and
-- several "LQ" entries were dead scene groups that were never low-bitrate. Replaced with a
-- seven-tier x265 ladder whose membership comes from Dictionarry's maintained tiers, plus a
-- local house tier for good x265 groups Dictionarry only lists in its x264-gated tiers.
--
-- Groups needing different treatment per arr (iVy, d3g, MeGusta/PSA) get their own custom
-- format so quality_profile_custom_formats.arr_type can score them differently.

-- ---------------------------------------------------------------- regular expressions

INSERT INTO regular_expressions (name, pattern, description) VALUES
 ('x265 Tier 1 Groups', '^(HONE)$', 'Top x265 encoder, Bluray and WEB'),
 ('x265 Tier 2 Groups', '^(NAN0|SQS|Vialle|QxR|afm72|Bandi|Celdra|FreetheFish|Garshasp|Ghost|Kappa|Langbard|LION|MONOLITH|Natty|Panda|RCVR|RZeroX|SAMPA|Silence|Tigole|YOGI|r00t|t3nzin|Ime|TAoE|Ainz|AJJMIN|ANONAZ|ArcX|DNU|DrainedDay|DUHIT|Erie|Frys|Goki|HxD|JBENT|Nostradamus|Species180|TheSickle|WEM|bccornfo|jb2049|r0b0t|xtrem3x)$', 'Dictionarry efficient tier 1 plus QxR and TAoE aliases'),
 ('x265 Tier 3 Groups', '^(BYNDR|CMRG|FLUX|HHWEB|Kitsune|MZABI|NTb|SMURF|TEPES|playWEB|WiKi|HiDt|UBits|YAWNTiC|GeneMige|BRUTE|SPHD|j3rico)$', 'WEB-DL HEVC tier 1 plus the local house tier of high-bitrate x265 encoders'),
 ('x265 Tier 4 Groups', '^(ARCADE|DarQ|LSt|MNHD|SARTRE|honeyvera|GRiMM|dkore|ToNaTo)$', 'Dictionarry efficient tiers 2 and 3'),
 ('x265 Tier 5 Groups', '^(Chivaman|R1GY3B|Ralphy|TimeDistortion|Vyndros|YELLO|bluegreeen|bluespots|cXcY|edge2020|noxxus|OnlyWeb)$', 'Dictionarry efficient tier 4'),
 ('x265 Tier 6 Groups', '^(Nb8|QAsH|WADU|HDSWEB)$', 'Unlisted by Dictionarry but measured acceptable in this library'),
 ('House TV Tier Groups', '^(RUDR|NORViNE|RAWR|KONTRAST)$', 'Measured high-bitrate TV groups absent from or bottom-ranked by Dictionarry'),
 ('x265 Tier 7 Groups', '^(PHOCiS|YAWNiX|HODL)$', 'Dictionarry bottom TV tiers'),
 ('Compact Re-encode Groups', '^(NeoNoir|D3FiL3R|JATT|DH|Lootera|KyoGo|B3YG1R)$', 'Unlisted compact re-encoders measured at 16-22 MB/min'),
 ('Group MeGusta PSA', '^(MeGusta|PSA)$', 'Micro-encoders, banned for film and neutral for TV'),
 ('Group SM737', '^(SM737)$', 'SM737 release group'),
 ('DV or HDR Claim', '(?i)\b(dv|dovi|dolby.?vision|hdr10\+|hdr10|hdr)\b', 'Release title claims Dolby Vision or HDR'),
 ('Banned Groups', '^(4K4U|AOC|AROMA|BLASPHEMY|BOLS|BTM|BeyondHD|BiTOR|CLASSiCALHD|CREATiVE24|Casius08|DRX|DeViSiVE|DepraveD|E|FGT|Flights|HDS|KC|LAMA|MAMA|MgB|NAHOM|NIMA4K|NaNi|NhaNc3|NiCEHEVC|NoGroup|OEPlus|OFT|PiRaTeS|RARBG|RARGB|SHD|STUTTERSHIT|SasukeducK|ShieldBearer|SumVision|TEKNO3D|Telly|TvR|UnKn0wn|VD0N|VECTOR|VisionXpert|YIFY|YTS|jennaortegaUHD|jff|nikt0|pmHD|rbb|tarunk9c|x0r)$', 'Dictionarry universal ban list, minus the groups scored per-arr'),
 ('Banned Dual Audio Groups', '^(CYPHER|SiGLA|TURG|alfahd)$', 'Dictionarry banned dual-audio groups');

-- ---------------------------------------------------------------- custom formats

INSERT INTO custom_formats (name, description) VALUES
 ('x265 Tier 1', 'Top x265 release groups'),
 ('x265 Tier 2', 'Excellent x265 release groups'),
 ('x265 Tier 3', 'Very good x265 and WEB-DL HEVC release groups'),
 ('x265 Tier 4', 'Good x265 release groups'),
 ('x265 Tier 5', 'Acceptable x265 release groups'),
 ('x265 Tier 6', 'Unranked but measured acceptable'),
 ('x265 Tier 7', 'Bottom of the ladder, last resort'),
 ('House TV Tier', 'Locally measured high-bitrate TV groups'),
 ('Compact Re-encode', 'Low-bitrate compact re-encoders'),
 ('Group iVy', 'iVy - banned for film, bottom tier for TV'),
 ('Group d3g', 'd3g - penalised for film, acceptable for TV'),
 ('Group MeGusta PSA', 'MeGusta and PSA - banned for film, neutral for TV'),
 ('SM737 Fake DV', 'SM737 releases claiming DV or HDR'),
 ('Banned Groups', 'Release groups banned outright'),
 ('Banned Dual Audio Groups', 'Groups whose audio track ordering breaks language detection');

-- ---------------------------------------------------------------- conditions

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required) VALUES
 ('x265 Tier 1', 'Tier 1 Groups', 'release_group', 'all', 0, 0),
 ('x265 Tier 2', 'Tier 2 Groups', 'release_group', 'all', 0, 0),
 ('x265 Tier 3', 'Tier 3 Groups', 'release_group', 'all', 0, 0),
 ('x265 Tier 4', 'Tier 4 Groups', 'release_group', 'all', 0, 0),
 ('x265 Tier 5', 'Tier 5 Groups', 'release_group', 'all', 0, 0),
 ('x265 Tier 6', 'Tier 6 Groups', 'release_group', 'all', 0, 0),
 ('x265 Tier 7', 'Tier 7 Groups', 'release_group', 'all', 0, 0),
 ('House TV Tier', 'House TV Groups', 'release_group', 'all', 0, 0),
 ('Compact Re-encode', 'Compact Groups', 'release_group', 'all', 0, 0),
 ('Group iVy', 'iVy', 'release_group', 'all', 0, 0),
 ('Group d3g', 'd3g', 'release_group', 'all', 0, 0),
 ('Group MeGusta PSA', 'MeGusta PSA', 'release_group', 'all', 0, 0),
 ('SM737 Fake DV', 'SM737', 'release_group', 'all', 0, 1),
 ('SM737 Fake DV', 'DV or HDR Claim', 'release_title', 'all', 0, 1),
 ('Banned Groups', 'Banned Groups', 'release_group', 'all', 0, 0),
 ('Banned Dual Audio Groups', 'Banned Dual Audio Groups', 'release_group', 'all', 0, 0);

INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name) VALUES
 ('x265 Tier 1', 'Tier 1 Groups', 'x265 Tier 1 Groups'),
 ('x265 Tier 2', 'Tier 2 Groups', 'x265 Tier 2 Groups'),
 ('x265 Tier 3', 'Tier 3 Groups', 'x265 Tier 3 Groups'),
 ('x265 Tier 4', 'Tier 4 Groups', 'x265 Tier 4 Groups'),
 ('x265 Tier 5', 'Tier 5 Groups', 'x265 Tier 5 Groups'),
 ('x265 Tier 6', 'Tier 6 Groups', 'x265 Tier 6 Groups'),
 ('x265 Tier 7', 'Tier 7 Groups', 'x265 Tier 7 Groups'),
 ('House TV Tier', 'House TV Groups', 'House TV Tier Groups'),
 ('Compact Re-encode', 'Compact Groups', 'Compact Re-encode Groups'),
 ('Group iVy', 'iVy', 'Group iVy'),
 ('Group d3g', 'd3g', 'Group d3g'),
 ('Group MeGusta PSA', 'MeGusta PSA', 'Group MeGusta PSA'),
 ('SM737 Fake DV', 'SM737', 'Group SM737'),
 ('SM737 Fake DV', 'DV or HDR Claim', 'DV or HDR Claim'),
 ('Banned Groups', 'Banned Groups', 'Banned Groups'),
 ('Banned Dual Audio Groups', 'Banned Dual Audio Groups', 'Banned Dual Audio Groups');

-- ---------------------------------------------------------------- retire the legacy lists
-- Dependents are removed explicitly rather than relying on ON DELETE CASCADE, which does not
-- fire unless PRAGMA foreign_keys is on.

DELETE FROM condition_patterns WHERE custom_format_name IN (
  'Trusted Movie Groups','Trusted TV Groups','LQ Groups','Bad Dual Groups','Language Not English');
DELETE FROM condition_languages WHERE custom_format_name IN (
  'Trusted Movie Groups','Trusted TV Groups','LQ Groups','Bad Dual Groups','Language Not English');
DELETE FROM custom_format_conditions WHERE custom_format_name IN (
  'Trusted Movie Groups','Trusted TV Groups','LQ Groups','Bad Dual Groups','Language Not English');
DELETE FROM custom_format_tags WHERE custom_format_name IN (
  'Trusted Movie Groups','Trusted TV Groups','LQ Groups','Bad Dual Groups','Language Not English');
DELETE FROM quality_profile_custom_formats WHERE custom_format_name IN (
  'Trusted Movie Groups','Trusted TV Groups','LQ Groups','Bad Dual Groups','Language Not English');
DELETE FROM custom_formats WHERE name IN (
  'Trusted Movie Groups','Trusted TV Groups','LQ Groups','Bad Dual Groups','Language Not English');
