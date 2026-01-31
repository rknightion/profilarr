# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a YAML configuration database for Radarr and Sonarr media servers, designed for use with Profilarr v1. It contains quality profiles, custom formats, and regex patterns optimized for x265 compact releases and 4K HDR content.

**No build system, tests, or linting** - this is a pure YAML configuration repository with no code to compile or validate.

## Repository Structure

```
custom_formats/     # Custom format definitions that reference regex patterns
regex_patterns/     # Reusable regex pattern definitions
profiles/           # Quality profiles for Radarr/Sonarr (1080p and 4K variants)
media_management/   # Naming conventions and quality definitions
```

## Key Conventions

### File Naming
- **Filename must exactly match the `name` field** inside the YAML file
- Spaces in filenames are allowed and expected (e.g., `x265 HEVC.yml`)

### Pattern Reference System
Custom formats reference regex patterns by name. The `pattern` field in a custom format condition matches a regex pattern file:

```yaml
# In custom_formats/x265 HEVC.yml
conditions:
  - pattern: x265 HEVC    # References regex_patterns/x265 HEVC.yml
```

### Score-Based Filtering
Profiles use scores to control release selection:
- Positive scores (1-100): Preferred releases
- Negative scores (-50 to -200): Avoided releases
- Score -10000: Hard block (never download)

### YAML Format
- Use single quotes for regex patterns: `pattern: '(?i)(x265|hevc)'`
- All regexes should be case-insensitive using `(?i)` prefix
- Custom formats include empty `tests: []` placeholder
