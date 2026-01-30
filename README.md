# Profilarr Database

Configuration database for **Radarr** and **Sonarr** - optimized for x265 compact releases.

Compatible with **Profilarr v1**.

## Structure

```
.
├── custom_formats/          # 22 custom format definitions
├── profiles/                # 4 quality profiles
│   ├── Radarr - 1080p x265 Compact.yml
│   ├── Radarr - 4K x265 DV HDR.yml
│   ├── Sonarr - 1080p x265 Compact.yml
│   └── Sonarr - 4K x265 DV HDR.yml
├── media_management/        # Media management settings
│   ├── naming.yml
│   └── quality_definitions.yml
├── regex/                   # 86 regex pattern definitions
│   ├── Codec patterns (x265, x264, AV1, etc.)
│   ├── HDR patterns (Dolby Vision, HDR10, HDR10+)
│   ├── Audio patterns (Atmos, DTS, Lossless)
│   ├── Release group patterns (Trusted, LQ, Bad Dual)
│   └── LQ indicator patterns
└── README.md
```

**Note:**
- File names must match the `name` field inside each YAML file
- Custom format conditions reference regex patterns by name
- Use single quotes for regex patterns in YAML

## Custom Formats

### Codec
- **x265 HEVC** - Matches x265/H.265/HEVC releases
- **10-bit** - Matches 10-bit color depth releases
- **Unwanted Codecs BLOCK** - Blocks x264, AV1, XviD, DivX, etc.

### HDR
- **DV HDR10 Compatible** - Dolby Vision with HDR10 fallback
- **DV No Fallback P5 AVOID** - DV Profile 5 without fallback
- **HDR10Plus** - HDR10+ dynamic metadata
- **HDR10** - Standard HDR10 (excludes DV/HDR10+)

### Audio
- **DD+ Atmos** - Dolby Digital Plus Atmos (preferred)
- **DDP 5.1** - Dolby Digital Plus 5.1
- **5.1 Surround** - Generic 5.1 audio
- **TrueHD Atmos AVOID** - Large lossless Atmos
- **DTS All AVOID** - All DTS formats
- **Lossless Audio AVOID** - TrueHD, DTS-HD MA, FLAC, PCM

### Release Groups
- **Trusted Movie Groups** - LAMA, PSA, NeoNoir, FLUX, BYNDR, etc.
- **Trusted TV Groups** - PSA, MeGusta, ELiTE, FLUX, NTb, etc.
- **LQ Groups** - FGT, STUTTERSHIT, SPARKS, etc.
- **Bad Dual Groups** - MULTiPLY, VHSRIP, XEN, etc.

### Language
- **Language Not English** - Blocks non-English releases
- **Dubbed Audio Title** - Matches dubbed/dual/multi audio
- **Line Mic Dubbed** - Blocks line/mic dubbed releases

### Other
- **PROPER REPACK** - Matches proper/repack releases
- **LQ Release Title** - Blocks known LQ title patterns

## Quality Profiles

### Radarr
- **Radarr - 1080p x265 Compact** - Efficient 1080p movies with x265
- **Radarr - 4K x265 DV HDR** - Premium 4K movies with HDR

### Sonarr
- **Sonarr - 1080p x265 Compact** - Efficient 1080p TV with x265
- **Sonarr - 4K x265 DV HDR** - Premium 4K TV with HDR

## Quality Definitions

Configured in `media_management/quality_definitions.yml` with separate sections for Radarr and Sonarr. Sonarr uses slightly lower bitrates suitable for TV content.

## Usage

### With Profilarr v1

1. Push this directory to a private GitHub repository
2. In Profilarr, add your repository URL
3. Use a Personal Access Token for private repo authentication
4. Add your Radarr/Sonarr instances with their API keys
5. Sync profiles and custom formats

## File Format Reference

### Regex Pattern YAML Structure
```yaml
name: Pattern Name
pattern: '(?i)regex-pattern-here'
description: "What this pattern matches"
tags:
  - Category
```

### Custom Format YAML Structure
```yaml
name: Format Name
description: "Brief description"
tags:
  - Category
conditions:
  - name: Condition Name
    type: release_title|release_group|language
    pattern: Pattern Name    # Reference to regex file
    negate: false
    required: true|false
tests: []
```

### Quality Profile YAML Structure
```yaml
name: Profile Name
description: "Brief description"
upgrade_allowed: true
min_format_score: 10
cutoff_format_score: 300
language: Original

qualities:
  - name: Quality Name
    allowed: true

format_scores:
  - name: Custom Format Name
    score: 100
```

---
*Configuration database for Radarr and Sonarr - Profilarr v1 compatible*
