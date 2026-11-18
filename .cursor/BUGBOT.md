# Profilarr database review

This repository provides ordered SQL operations and a dependency manifest
for a Profilarr v2 database consumed by Radarr and Sonarr. Keep existing
operations append-only. Review new operations in numeric order and check
that expected-value guards report conflicts and that references resolve
against the declared schema dependency.

Check format scores, thresholds and group regex changes together. Verify
that fallback releases can rank as intended without outranking preferred
ones, and keep hard blocks distinct from preference penalties. Treat quality
and language names as dependency contracts.

CI validates `pcd.json`. Use the local replay in `AGENTS.md` to verify the
declared schema and every operation, then check that SQLite reports no
foreign-key errors. Focus review on the resulting behavior as well as the
SQL syntax.
