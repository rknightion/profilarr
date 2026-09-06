# profilarr

A **Profilarr v2 Compliant Database (PCD)** for Radarr/Sonarr: curated x265 / 4K HDR quality
profiles, custom formats and regex patterns. Consumed by Profilarr v2, not v1.

## The data model is Operational SQL, not state

The database is an ordered, **append-only** sequence of SQL operations that build the state by
replay. `ops/N.name.sql` files are the content; each carries `@operation` / `@opIds` headers.

- **Author edits in the Profilarr v2 app, export them as a new numbered op, commit that.** Never
  rewrite an existing op to change behaviour: later ops override earlier ones, and expected-value
  guards (`... AND score = 400`) are what make a conflict explicit instead of silent.
- `ops/1.initial.sql` is the generated initial import of the entire v1 database.
- The v1 YAML layout was removed. Do not hand-edit or recreate it; the snapshot lives at git tag
  `v1-final`.
- `tweaks/` holds optional variant operations.

## The schema lives in another repo

Table DDL, base languages and canonical qualities come from the `schema` PCD
(`https://github.com/Dictionarry-Hub/schema`), pinned in `pcd.json` under `dependencies`. Nothing in
this repo defines them. Custom-format, quality and language names must match that PCD's canonical
names exactly.

## Validate locally

CI only checks that `pcd.json` parses. The real check is that the OSQL replays cleanly: build a
throwaway SQLite DB from the `schema` PCD's ops, then every op here in order, and run
`PRAGMA foreign_key_check;` - empty output means clean.

```bash
git clone --depth 1 https://github.com/Dictionarry-Hub/schema /tmp/pcd-schema
DB=/tmp/verify.db; rm -f "$DB"
for f in /tmp/pcd-schema/ops/*.sql; do sqlite3 "$DB" < "$f"; done
for f in ops/*.sql; do sqlite3 "$DB" < "$f"; done
sqlite3 "$DB" "PRAGMA foreign_key_check;"
```

Replaying only `ops/1.initial.sql` skips every later operation and so proves nothing about the ops
you just added.

## Reading the data

- **Scores**: positive = preferred, negative = avoided, `-10000` = hard block (never download).
- Profiles assign per-arr custom-format scores through
  `quality_profile_custom_formats.arr_type` (`all` / `radarr` / `sonarr`).
