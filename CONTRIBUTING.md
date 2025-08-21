# Contributing

Thanks for considering a contribution! This repo is intentionally small but aims for excellent DX and code quality.

## Project setup

```bash
git clone https://github.com/rurfy/habit-tracker.git
cd habit-tracker/frontend
flutter pub get
```

## Commands

```bash
# format (fails CI if changes are needed)
dart format --output=none --set-exit-if-changed .

# static analysis
flutter analyze

# run tests + coverage
flutter test --coverage
```

## Commit style

Use **Conventional Commits**:
- `feat:` new feature
- `fix:` bug fix
- `docs:`, `chore:`, `refactor:`, `test:` …

Example: `feat(stats): show 7-day completion chart`

## Pull Requests

- Keep PRs small and focused.
- Include tests for new logic.
- Ensure `flutter analyze` passes with 0 warnings.
- Update docs/README if behavior changes.
