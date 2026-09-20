-- @operation: update
-- @entity: delay_profiles
-- @name: Real delay windows, with a score bypass, and a separate TV profile
--
-- bypass_if_highest_quality = 1 is why the existing 120-minute delay did nothing: the cutoff is the
-- merged "Good 1080p" quality group, so every WEBRip/WEBDL/Bluray-1080p release is already at the
-- highest allowed quality and bypassed the wait immediately. That single flag is why the first
-- eligible release always won. Turned off, and replaced with a bypass on custom format score so a
-- tier-1 or tier-2 release still grabs on sight while anything weaker waits for something better.
--
-- Threshold sizing: custom format scores STACK, so a bypass set at the bare tier-1 group score is
-- reachable by a much weaker release carrying 10-bit, Atmos and HDR. Worked from the other end
-- instead - the thresholds are set above the best score a poor release can reach:
--   film: tier 6 fully loaded = 200+100+50+100+100 = 550, so 650 keeps it waiting
--   TV:   iVy fully loaded    = 150+100+50+100     = 400, MeGusta = 250, so 550 keeps both waiting
-- Tier 1 bare (600+100 film, 520+100 TV) clears both, which is the intent.
--
-- Default is the film profile (24h). A second profile carries the TV window (12h) because
-- delay_profiles has no arr_type; Profilarr points each arr instance at one by name.

-- torrent_delay is guarded against BOTH known prior values. The repo and the live Profilarr state
-- had diverged: an op authored in the app on 2026-05-25 set torrent_delay to 120 and was never
-- pushed, so a clean replay of this repo sees 10 while the live instance sees 120. Pinning to a
-- single value would silently no-op in one of the two paths. The other three columns are identical
-- in both and so are pinned normally.

update "delay_profiles" set "torrent_delay" = 1440 where "name" = 'Default' and "torrent_delay" IN (10, 120);
update "delay_profiles" set "usenet_delay" = 1440 where "name" = 'Default' and "usenet_delay" = 600;
update "delay_profiles" set "bypass_if_highest_quality" = 0 where "name" = 'Default' and "bypass_if_highest_quality" = 1;
update "delay_profiles" set "bypass_if_above_custom_format_score" = 1, "minimum_custom_format_score" = 650 where "name" = 'Default' and "bypass_if_above_custom_format_score" = 0;

INSERT INTO delay_profiles
  (name, preferred_protocol, usenet_delay, torrent_delay, bypass_if_highest_quality, bypass_if_above_custom_format_score, minimum_custom_format_score)
VALUES
  ('TV', 'prefer_torrent', 720, 720, 0, 1, 550);
