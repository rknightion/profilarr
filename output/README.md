# My Profilarr Database

Private Profilarr-compatible database for syncing custom formats and quality profiles between Radarr and Sonarr instances.

## Repository Structure

```
.
├── custom_formats/     # Custom format definitions
├── profiles/           # Quality profile definitions  
├── regex_patterns/     # (Optional) Shared regex patterns
└── README.md
```

## Custom Formats

| Format | Purpose | Score Recommendation |
|--------|---------|---------------------|
| x265 HEVC | Prefer HEVC/H.265 codec | +100 |
| 10-bit | Prefer 10-bit color depth | +50 |
| DD+ Atmos | Prefer Dolby Digital Plus with Atmos | +100 |
| DDP 5.1 | Prefer DD+ 5.1 surround | +75 |
| 5.1 Surround | Basic 5.1 surround (not DDP) | +25 |
| DV HDR10 Compatible | Dolby Vision with HDR10 fallback | +500 |
| HDR10Plus | HDR10+ content | +200 |
| HDR10 | Standard HDR10 | +100 |
| Trusted Movie Groups | Quality release groups for movies | +50 |
| Trusted TV Groups | Quality release groups for TV | +50 |
| x264 BLOCK | Block H.264 content | -10000 |
| BR-DISK Remux BLOCK | Block BR-DISK and Remux | -10000 |
| Foreign Language BLOCK | Block non-English releases | -10000 |
| Dubbed Bad Groups BLOCK | Block dubbed and bad release groups | -10000 |
| DTS All AVOID | Avoid DTS audio (large files) | -100 |
| TrueHD Atmos AVOID | Avoid TrueHD Atmos (large files) | -100 |
| Lossless Audio AVOID | Avoid lossless audio (large files) | -100 |
| DV No Fallback P5 AVOID | Avoid DV without HDR fallback | -500 |
| Unwanted Formats AVOID | Avoid legacy codecs | -500 |

## Quality Profiles

- **1080p Streaming** - Optimized for 1080p content, prefers x265 and streaming-friendly audio
- **4K HDR** - Optimized for 4K HDR content, prefers DV with HDR10 fallback

## Usage with Profilarr

1. Add this repository as a remote database in Profilarr
2. Select the custom formats and profiles you want
3. Sync to your Radarr/Sonarr instances

## Maintenance

Edit files directly in this repo or through the Profilarr UI. Changes are automatically tracked via git.

---

*Managed with [Profilarr](https://github.com/Dictionarry-Hub/profilarr)*
