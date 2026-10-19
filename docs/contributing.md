# Contributing

- Read `CLAUDE.md` and `.claude/rules/` for conventions.
- Keep logic in `TwoFACore` with tests; keep views thin.
- All user-facing text goes in `AppCopy` (English and Spanish).
- Optional behavior needs an `AppSettings` switch.
- Commit small, focused steps: `feat:`, `fix:`, `docs:`, `chore:`, `build:`.
- Run `swift build && swift test` before committing.
- Never commit real secrets or backups (`data-example.json` is gitignored).
- Do not add network calls, analytics or cloud sync.
