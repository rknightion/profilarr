# rk-profilarr-db

A curated **Profilarr Compliant Database (PCD)** of x265 / 4K‑HDR quality profiles, custom formats, and regex patterns for **Radarr** and **Sonarr**.

Built for **Profilarr v2** (`minimum_version` 2.0.0). The legacy v1 YAML version is preserved at the **`v1-final`** git tag.

## What's inside

- **2 quality profiles** — `1080p x265 Compact`, `4K x265 DV HDR`
- **25 custom formats** — codec (x265, 10‑bit), HDR (Dolby Vision, HDR10, HDR10+), audio (Atmos, DDP, surround), trusted/LQ release groups, language and junk blocks
- **86 regex patterns**
- Media management — naming schemes and quality definitions for Radarr & Sonarr

## Structure (PCD / OSQL)

```
pcd.json            # manifest: identity, arr types, schema dependency, min Profilarr version
ops/                # ordered, append-only SQL operations ("OSQL") that build the database
  └── 1.initial.sql # full initial state (converted from the v1 YAML via rosettarr)
tweaks/             # optional variant operations (empty placeholder)
```

A PCD describes the database as a *sequence of operations*, not final state. The table schema (DDL), languages, and canonical qualities come from the [`schema`](https://github.com/Dictionarry-Hub/schema) PCD declared as a dependency in `pcd.json`; this repo's `ops/` add the data on top.

## Use it in Profilarr v2

1. **Databases → Link** → repository URL `https://github.com/rknightion/profilarr`, branch `main`. Profilarr resolves the `schema` dependency automatically.
2. Add your Radarr/Sonarr instances (Settings → Arr).
3. Assign the profiles you want to each instance and sync.

## Maintaining it

Make edits in the **Profilarr v2 app**, which exports each change as a new ordered `ops/N.*.sql` file — commit those. Don't hand‑edit YAML (it's been retired; the v1 snapshot lives at tag `v1-final`). To let Profilarr push in‑app edits back here, add a GitHub PAT to the linked database in Profilarr.

## Validate locally

```bash
git clone --depth 1 https://github.com/Dictionarry-Hub/schema /tmp/pcd-schema
DB=/tmp/verify.db; rm -f "$DB"
for f in 0.schema 1.languages 2.qualities 3.quality-group-member-position; do
  sqlite3 "$DB" < /tmp/pcd-schema/ops/$f.sql; done
sqlite3 "$DB" < ops/1.initial.sql
sqlite3 "$DB" "PRAGMA foreign_key_check;"   # should print nothing
```
