# Profilarr Database

Configuration database for **Radarr** and **Sonarr** - optimized for x265 compact releases.

Compatible with **Profilarr v1**.

## Structure

```
.
├── custom_formats/          # 22 custom format definitions (shared)
│   ├── 10-bit.yml
│   ├── 5.1 Surround.yml
│   ├── Bad Dual Groups.yml
│   ├── DD+ Atmos.yml
│   ├── DDP 5.1.yml
│   ├── DTS All AVOID.yml
│   ├── DV HDR10 Compatible.yml
│   ├── DV No Fallback P5 AVOID.yml
│   ├── Dubbed Audio Title.yml
│   ├── HDR10.yml
│   ├── HDR10Plus.yml
│   ├── Language: Not English.yml
│   ├── Line Mic Dubbed.yml
│   ├── Lossless Audio AVOID.yml
│   ├── LQ Groups.yml
│   ├── LQ Release Title.yml
│   ├── PROPER REPACK.yml
│   ├── TrueHD Atmos AVOID.yml
│   ├── Trusted Movie Groups.yml
│   ├── Trusted TV Groups.yml
│   ├── Unwanted Codecs BLOCK.yml
│   └── x265 HEVC.yml
├── profiles/                # Quality profiles
│   ├── Radarr - 1080p x265 Compact.yml
│   ├── Radarr - 4K x265 DV HDR.yml
│   ├── Sonarr - 1080p x265 Compact.yml
│   └── Sonarr - 4K x265 DV HDR.yml
├── media_management/        # Media management settings
│   ├── naming.yml
│   └── quality_definitions.yml
└── README.md
```

**Note:** File names must match the `name` field inside each YAML file for Profilarr v1 compatibility.

## Custom Formats by Category

### Codec
| Format | Description |
|--------|-------------|
| x265 HEVC | Matches x265/H.265/HEVC releases |
| 10-bit | Matches 10-bit color depth releases |
| Unwanted Codecs BLOCK | Blocks x264, AV1, XviD, DivX, etc. |

### HDR
| Format | Description |
|--------|-------------|
| DV HDR10 Compatible | Dolby Vision with HDR10 fallback |
| DV No Fallback P5 AVOID | DV Profile 5 without fallback |
| HDR10Plus | HDR10+ dynamic metadata |
| HDR10 | Standard HDR10 (excludes DV/HDR10+) |

### Audio
| Format | Description |
|--------|-------------|
| DD+ Atmos | Dolby Digital Plus Atmos (preferred) |
| DDP 5.1 | Dolby Digital Plus 5.1 |
| 5.1 Surround | Generic 5.1 audio |
| TrueHD Atmos AVOID | Large lossless Atmos |
| DTS All AVOID | All DTS formats |
| Lossless Audio AVOID | TrueHD, DTS-HD MA, FLAC, PCM |

### Release Groups
| Format | Description |
|--------|-------------|
| Trusted Movie Groups | LAMA, PSA, NeoNoir, FLUX, BYNDR, etc. |
| Trusted TV Groups | PSA, MeGusta, ELiTE, FLUX, NTb, etc. |
| LQ Groups | FGT, STUTTERSHIT, SPARKS, etc. |
| Bad Dual Groups | MULTiPLY, VHSRIP, XEN, etc. |

### Language
| Format | Description |
|--------|-------------|
| Language: Not English | Blocks non-English releases |
| Dubbed Audio Title | Matches dubbed/dual/multi audio |
| Line Mic Dubbed | Blocks line/mic dubbed releases |

### Other
| Format | Description |
|--------|-------------|
| PROPER REPACK | Matches proper/repack releases |
| LQ Release Title | Blocks known LQ title patterns |

## Quality Profiles

### Radarr Profiles

#### Radarr - 1080p x265 Compact
- **Target**: Efficient 1080p movie releases with x265 codec
- **Min Score**: 10
- **Cutoff Score**: 300
- **Priorities**: x265 (+100), DD+ Atmos (+100), 10-bit (+50), DV HDR10 (+50)
- **Blocks**: x264/AV1, LQ groups, non-English

#### Radarr - 4K x265 DV HDR
- **Target**: Premium 4K movie releases with HDR
- **Min Score**: 10
- **Cutoff Score**: 500
- **Priorities**: DV HDR10 (+200), x265 (+150), HDR10+ (+100), DD+ Atmos (+100)
- **Blocks**: Same as 1080p, stricter on dubbed content

### Sonarr Profiles

#### Sonarr - 1080p x265 Compact
- **Target**: Efficient 1080p TV releases with x265 codec
- **Min Score**: 10
- **Cutoff Score**: 300
- **Priorities**: x265 (+100), DD+ Atmos (+100), 10-bit (+50), DV HDR10 (+50)
- **Blocks**: x264/AV1, LQ groups, non-English

#### Sonarr - 4K x265 DV HDR
- **Target**: Premium 4K TV releases with HDR
- **Min Score**: 10
- **Cutoff Score**: 500
- **Priorities**: DV HDR10 (+200), x265 (+150), HDR10+ (+100), DD+ Atmos (+100)
- **Blocks**: Same as 1080p, stricter on dubbed content

## Quality Definitions

Quality size limits (MB/minute) are configured separately for Radarr and Sonarr in `media_management/quality_definitions.yml`. Sonarr uses slightly lower bitrates suitable for TV content.

## Usage

### With Profilarr v1

1. Push this directory to a private GitHub repository
2. In Profilarr, add your repository URL
3. Use a Personal Access Token for private repo authentication
4. Add your Radarr/Sonarr instances with their API keys
5. Sync profiles and custom formats

### Manual Import

Custom formats can be imported directly into Radarr/Sonarr:
1. Convert YAML back to JSON if needed
2. Use Settings → Custom Formats → Import

## File Format Reference

### Custom Format YAML Structure
```yaml
name: Format Name
description: "Brief description"
tags:
  - Category
conditions:
  - name: Condition Name
    type: release_title|release_group|language|source|resolution
    pattern: "regex-pattern"    # for release_title/release_group
    language: 1                  # for language (1=English)
    negate: false
    required: true|false
tests: []
include_in_rename: false        # optional
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

### Quality Definitions YAML Structure
```yaml
quality_definitions:
  radarr:
    Quality-Name:
      min: 0
      max: 100
      preferred: 95
  sonarr:
    Quality-Name:
      min: 0
      max: 100
      preferred: 95
```

---
*Configuration database for Radarr and Sonarr - Profilarr v1 compatible*
