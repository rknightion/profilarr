-- @operation: update
-- @entity: batch
-- @name: Block Opus and Vorbis audio, which the LG C2 cannot direct play
--
-- Measured 2026-11-27: The Social Reckoning (WEBRip Opus 5.1 x265-Lootera) stalled about two
-- minutes into playback on the LG OLED65C24LA. The LG Plex app cannot direct play Opus, so it
-- asked for Direct Stream: Plex copied the HEVC video, transcoded the audio to AAC and sent it as
-- HLS. The TV then re-requested segments 12 and 13 about 45 times a second until playback was
-- stopped, while Plex was throttling well ahead. That retry storm appears once in 30 days of Plex
-- logs. The same file direct-played cleanly on a Fire TV, so the file was not corrupt: the
-- codec forces the TV onto its HLS path, which also failed in October for a different trigger.
-- Replacing it with a DD+ Atmos release fixed playback.
--
-- Why a block and not a penalty: the profile minimum is -1000, and any penalty large enough to
-- rank Opus below every acceptable DD+/AC3/AAC release also pushes it under that floor. A
-- missing film stays monitored and is grabbed when a playable release appears; a stalling one
-- looks fine in the library until someone presses play.
--
-- Matched on the release title, so the word must be followed by a channel layout (Opus 5 1,
-- Opus.5.1, Opus5.1, Opus 2.0) or a codec token. That keeps the h264 releases from the group
-- named OPUS and films titled Opus (Mr. Holland's Opus, Opus 2025) out of the match. Tested
-- against the 47 distinct Opus release titles in Radarr and Sonarr history.

INSERT INTO regular_expressions (name, pattern, description) VALUES
 ('Opus or Vorbis Audio',
  '(?i)\b(opus|vorbis)(?:[ ._-]?[1-8][ ._][0-2]\b|(?=[ ._-]+(?:x26[45]|h[ .]?26[45]|hevc|av1)\b))',
  'Opus or Vorbis audio named with a channel layout or a codec token, so the group OPUS and titles containing Opus do not match');

INSERT INTO regular_expression_tags (regular_expression_name, tag_name) VALUES
 ('Opus or Vorbis Audio', 'Audio');

INSERT INTO custom_formats (name, description) VALUES
 ('Opus Vorbis BLOCK', 'Blocks Opus and Vorbis audio - the LG C2 Plex app cannot direct play them and stalls on the Direct Stream fallback');

INSERT INTO custom_format_tags (custom_format_name, tag_name) VALUES
 ('Opus Vorbis BLOCK', 'Audio'),
 ('Opus Vorbis BLOCK', 'Unwanted');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required) VALUES
 ('Opus Vorbis BLOCK', 'Opus or Vorbis', 'release_title', 'all', 0, 1);

INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name) VALUES
 ('Opus Vorbis BLOCK', 'Opus or Vorbis', 'Opus or Vorbis Audio');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score) VALUES
 ('1080p x265 Compact', 'Opus Vorbis BLOCK', 'all', -10000),
 ('4K x265 DV HDR',     'Opus Vorbis BLOCK', 'all', -10000),
 ('1080p x265 TV',      'Opus Vorbis BLOCK', 'all', -10000);
