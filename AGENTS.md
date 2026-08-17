# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Profilarr v2 Compliant Database (PCD)** for Radarr/Sonarr — curated x265 / 4K‑HDR quality profiles, custom formats, and regex patterns. It is consumed by **Profilarr v2** (not v1).

A PCD is **Operational SQL (OSQL)**: the database is defined as an ordered, append‑only sequence of SQL operations that build the state by replay — not as stateful YAML. Migrated from the former v1 YAML layout via [`rosettarr`](https://github.com/Dictionarry-Hub/rosettarr); that snapshot is preserved at git tag **`v1-final`**.

## Repository Structure

```
pcd.json    # manifest — name, version, arr_types, dependency on the `schema` PCD, profilarr.minimum_version
ops/        # ordered, append-only OSQL files (N.name.sql) — the database content
tweaks/     # optional variant operations
```

The table schema (DDL), base languages, and canonical qualities are provided by the **`schema`** dependency (`https://github.com/Dictionarry-Hub/schema`) declared in `pcd.json` — not stored in this repo.

## How changes are made

- **Author edits in the Profilarr v2 app**, then export them as new numbered `ops/*.sql` (each carries `@operation` / `@opIds` headers) and commit. This is "Change‑Driven Development": every change is one append‑only operation; later ops override earlier ones; expected‑value guards (e.g. `... AND score = 400`) make conflicts explicit.
- **Do not** hand‑edit or recreate the old v1 YAML directories — they have been removed (recoverable from tag `v1-final`).
- `ops/1.initial.sql` is the rosettarr‑generated initial import of the entire v1 database.

## Validate locally (no build system)

To check the OSQL composes cleanly, build a throwaway SQLite DB from the `schema` PCD's ops, then this repo's ops, and run `PRAGMA foreign_key_check;` (expect empty output):

```bash
git clone --depth 1 https://github.com/Dictionarry-Hub/schema /tmp/pcd-schema
DB=/tmp/verify.db; rm -f "$DB"
for f in 0.schema 1.languages 2.qualities 3.quality-group-member-position; do
  sqlite3 "$DB" < /tmp/pcd-schema/ops/$f.sql; done
sqlite3 "$DB" < ops/1.initial.sql
sqlite3 "$DB" "PRAGMA foreign_key_check;"
```

## Conventions (for reading the data)

- **Scores**: positive = preferred; negative = avoided; `-10000` = hard block (never download).
- Profiles assign per‑arr custom‑format scores via `quality_profile_custom_formats.arr_type` (`all` / `radarr` / `sonarr`).
- Custom‑format, quality, and language names must match the canonical names defined by the `schema` PCD.
