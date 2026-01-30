# Profilarr Custom Database Setup Guide

## Overview

This guide will help you set up a private Profilarr/Dictionarry database with your custom quality profiles and custom formats, stored in a private GitHub repository and synced across your Radarr and Sonarr instances.

**Key Finding:** You're correct that Profilarr does **not** have a built-in import function for existing Radarr/Sonarr JSON exports. This is a [requested feature (GitHub issue #178)](https://github.com/Dictionarry-Hub/profilarr/issues/178) but hasn't been implemented yet. The converter script included in this package solves this problem by transforming your JSON exports to the Profilarr YAML format.

---

## Quick Start

### 1. Convert Your Existing Custom Formats

Your JSON files have been converted to Profilarr YAML format in the `profilarr-output/custom_formats/` directory.

To convert additional files in the future:

```bash
python convert_to_profilarr.py /path/to/json/files /path/to/output
```

### 2. Set Up Your Private GitHub Repository

Create a new **private** repository on GitHub (e.g., `my-profilarr-database`) with this structure:

```
my-profilarr-database/
├── custom_formats/          # Your converted YAML files go here
│   ├── 10-bit.yml
│   ├── 5-1-surround.yml
│   ├── br-disk-remux-block.yml
│   ├── dd-atmos.yml
│   ├── ddp-5-1.yml
│   ├── dts-all-avoid.yml
│   ├── dubbed-bad-groups-block.yml
│   ├── dv-hdr10-compatible.yml
│   ├── dv-no-fallback-p5-avoid.yml
│   ├── foreign-language-block.yml
│   ├── hdr10.yml
│   ├── hdr10plus.yml
│   ├── lossless-audio-avoid.yml
│   ├── truehd-atmos-avoid.yml
│   ├── trusted-movie-groups.yml
│   ├── trusted-tv-groups.yml
│   ├── unwanted-formats-avoid.yml
│   ├── x264-block.yml
│   └── x265-hevc.yml
├── profiles/                # Quality profiles (create these manually)
│   ├── 1080p-streaming.yml
│   └── 4k-hdr.yml
├── regex_patterns/          # Optional: Shared regex patterns
│   └── common-groups.yml
└── README.md
```

### 3. Deploy Profilarr

Add this to your Docker Compose:

```yaml
services:
  profilarr:
    image: ghcr.io/dictionarry-hub/profilarr:latest
    container_name: profilarr
    ports:
      - "6868:6868"
    volumes:
      - /path/to/profilarr/config:/config
    environment:
      - TZ=Europe/London
    restart: unless-stopped
```

### 4. Connect Your Private Database

1. Open Profilarr at `http://your-server:6868`
2. Go to **Settings** → **Databases** (or Remote Repos)
3. Add your private GitHub repository URL
4. If using a private repo, you'll need to configure authentication:
   - Generate a GitHub Personal Access Token with `repo` scope
   - Add the token in Profilarr's authentication settings

### 5. Connect Your Arr Instances

1. In Profilarr, go to **Settings** → **Instances** (or Bridge)
2. Add your Radarr instance:
   - Name: `Radarr`
   - URL: `http://radarr:7878` (or your Radarr URL)
   - API Key: Your Radarr API key (Settings → General)
3. Add your Sonarr instance similarly

### 6. Sync Your Configurations

1. Select the custom formats you want to sync
2. Choose the target instance(s)
3. Click **Sync** to push configurations

---

## File Format Reference

### Custom Format YAML Structure

```yaml
name: Format Name
description: "Brief description of what this format matches"
tags:
  - Audio
  - HDR
  - Custom
conditions:
  - name: Condition Name
    type: release_title          # See condition types below
    pattern: "(?i)your-regex"    # The regex pattern
    negate: false                # true = must NOT match
    required: true               # true = condition must be met
tests: []                        # Optional test cases
```

### Condition Types

| Type | Description |
|------|-------------|
| `release_title` | Match against release/torrent name (most common) |
| `release_group` | Match release group name |
| `source` | Match source type (Blu-ray, WEB-DL, etc.) |
| `resolution` | Match resolution |
| `language` | Match language |
| `edition` | Match edition (Director's Cut, etc.) |
| `indexer_flag` | Match indexer-specific flags |

### Quality Profile YAML Structure

```yaml
name: Profile Name
description: "Profile description"
upgrade_allowed: true
cutoff: WEBDL-1080p
min_format_score: 0
cutoff_format_score: 10000
items:
  - name: WEB 1080p
    allowed: true
    items:
      - name: WEBDL-1080p
      - name: WEBRip-1080p
  - name: Bluray-1080p
    allowed: true
format_scores:
  - name: x265 HEVC
    score: 100
  - name: DDP 5.1
    score: 50
  - name: Unwanted Formats AVOID
    score: -10000
```

---

## Your Converted Files Summary

The following custom formats have been converted:

| Original JSON | Converted YAML | Tags |
|---------------|----------------|------|
| cf-10bit.json | 10-bit.yml | Codec |
| cf-51-surround.json | 5-1-surround.yml | Audio |
| cf-brdisk-remux-block.json | br-disk-remux-block.yml | Quality, Unwanted |
| cf-ddp-atmos.json | dd-atmos.yml | Audio |
| cf-ddp51.json | ddp-5-1.yml | Audio |
| cf-dts-avoid.json | dts-all-avoid.yml | Audio, Unwanted |
| cf-dubbed-bad-groups-block.json | dubbed-bad-groups-block.yml | Language, Unwanted |
| cf-dv-hdr10-compatible.json | dv-hdr10-compatible.yml | HDR |
| cf-dv-no-hdr-avoid.json | dv-no-fallback-p5-avoid.yml | HDR, Unwanted |
| cf-foreign-language-block.json | foreign-language-block.yml | Language, Unwanted |
| cf-hdr10.json | hdr10.yml | HDR |
| cf-hdr10plus.json | hdr10plus.yml | HDR |
| cf-lossless-audio-avoid.json | lossless-audio-avoid.yml | Audio, Unwanted |
| cf-truehd-atmos-avoid.json | truehd-atmos-avoid.yml | Audio, Unwanted |
| cf-trusted-movie-groups.json | trusted-movie-groups.yml | Release Group |
| cf-trusted-tv-groups.json | trusted-tv-groups.yml | Release Group |
| cf-unwanted-formats-avoid.json | unwanted-formats-avoid.yml | Codec, Unwanted |
| cf-x264-block.json | x264-block.yml | Codec, Unwanted |
| cf-x265-hevc.json | x265-hevc.yml | Codec |

---

## Creating Quality Profiles

Quality profiles define which qualities are acceptable and how custom formats affect scoring. Here's an example for your use case:

### Example: 1080p Streaming Profile

Create `profiles/1080p-streaming.yml`:

```yaml
name: 1080p Streaming
description: "Optimized for 1080p streaming with x265 preference and good audio"
upgrade_allowed: true
cutoff: WEBDL-1080p
min_format_score: 0
cutoff_format_score: 500

# Quality groups and their order
items:
  - name: WEB 1080p
    allowed: true
    items:
      - name: WEBDL-1080p
      - name: WEBRip-1080p
  - name: HDTV-1080p
    allowed: true
  - name: Bluray-1080p
    allowed: false    # Disable to prefer streaming-optimized

# Custom format scoring
format_scores:
  # Preferred codecs
  - name: x265 HEVC
    score: 100
  - name: 10-bit
    score: 50
  
  # Preferred audio
  - name: DD+ Atmos
    score: 100
  - name: DDP 5.1
    score: 75
  - name: 5.1 Surround
    score: 25
  
  # Avoid these (negative scores)
  - name: x264 BLOCK
    score: -10000
  - name: DTS All AVOID
    score: -100
  - name: TrueHD Atmos AVOID
    score: -100
  - name: Lossless Audio AVOID
    score: -100
  - name: BR-DISK Remux BLOCK
    score: -10000
  
  # Hard blocks (very negative)
  - name: Foreign Language BLOCK
    score: -10000
  - name: Dubbed Bad Groups BLOCK
    score: -10000
  - name: Unwanted Formats AVOID
    score: -10000
  
  # Release groups
  - name: Trusted TV Groups
    score: 50
  - name: Trusted Movie Groups
    score: 50
```

### Example: 4K HDR Profile

Create `profiles/4k-hdr.yml`:

```yaml
name: 4K HDR
description: "4K with HDR preference, DV compatible"
upgrade_allowed: true
cutoff: WEBDL-2160p
min_format_score: 0
cutoff_format_score: 1000

items:
  - name: WEB 2160p
    allowed: true
    items:
      - name: WEBDL-2160p
      - name: WEBRip-2160p
  - name: Bluray-2160p
    allowed: false

format_scores:
  # HDR scoring
  - name: DV HDR10 Compatible
    score: 500
  - name: HDR10Plus
    score: 200
  - name: HDR10
    score: 100
  - name: DV No Fallback P5 AVOID
    score: -500    # Avoid DV without HDR fallback
  
  # Codec
  - name: x265 HEVC
    score: 100
  - name: 10-bit
    score: 50
  
  # Audio (streaming-friendly)
  - name: DD+ Atmos
    score: 100
  - name: DDP 5.1
    score: 75
  - name: DTS All AVOID
    score: -100
  - name: TrueHD Atmos AVOID
    score: -100
  - name: Lossless Audio AVOID
    score: -100
  
  # Blocks
  - name: BR-DISK Remux BLOCK
    score: -10000
  - name: Foreign Language BLOCK
    score: -10000
  - name: Dubbed Bad Groups BLOCK
    score: -10000
  - name: Unwanted Formats AVOID
    score: -10000
```

---

## Workflow Summary

1. **Initial Setup:**
   - Convert existing JSON → YAML using the converter script
   - Push to private GitHub repo
   - Connect Profilarr to your repo
   - Add Radarr/Sonarr instances

2. **Making Changes:**
   - Edit YAML files directly in your repo, OR
   - Make changes in Profilarr UI (they save to your local config)
   - Commit changes to keep version history

3. **Syncing:**
   - Profilarr pushes custom formats and profiles to your arr instances
   - Can be done manually or on a schedule

---

## Troubleshooting

### Custom formats not appearing in Radarr/Sonarr
- Verify the YAML syntax is correct
- Check Profilarr logs for sync errors
- Ensure API keys are correct

### Regex patterns not matching as expected
- Test patterns at [regex101.com](https://regex101.com) (use PCRE2 mode)
- Ensure `(?i)` flag is included for case-insensitive matching
- Check for proper escaping of special characters

### Private repo authentication issues
- Use a GitHub Personal Access Token with `repo` scope
- Ensure the token hasn't expired
- Check that the repo URL is correct (https format)

---

## Alternative: Using Profilarr V1 (Legacy Scripts)

If you prefer command-line tools, the older Profilarr V1 (by gnarr) supports export/import scripts:

```bash
# Clone the legacy version
git clone https://github.com/gnarr/Profilarr.git

# Export from existing instance
python exportarr.py

# Files go to ./exports/ directory
# Import to another instance
python importarr.py

# Sync between instances
python syncarr.py
```

This method uses the native Radarr/Sonarr JSON format directly without YAML conversion.

---

## Resources

- [Profilarr GitHub](https://github.com/Dictionarry-Hub/profilarr)
- [Dictionarry Database](https://github.com/Dictionarry-Hub/dictionarry)
- [Profilarr Documentation](https://dictionarry.dev)
- [TRaSH Guides](https://trash-guides.info/) (for reference, even if you're using custom configs)

---

*Guide generated by Claude (Anthropic) for Rob's home lab setup*
