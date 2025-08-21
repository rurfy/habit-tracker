<p align="center">
  <a href="https://github.com/rurfy/habit-tracker/actions/workflows/ci.yml">
    <img alt="CI" src="https://github.com/rurfy/habit-tracker/actions/workflows/ci.yml/badge.svg">
  </a>
  <a href="https://codecov.io/gh/rurfy/habit-tracker">
    <img alt="Coverage" src="https://codecov.io/gh/rurfy/habit-tracker/branch/main/graph/badge.svg">
  </a>
  <a href="https://rurfy.github.io/habit-tracker/">
    <img alt="Web Demo" src="https://img.shields.io/badge/web-demo-blue">
  </a>
  <a href="https://github.com/rurfy/habit-tracker/releases">
    <img alt="Releases" src="https://img.shields.io/github/v/release/rurfy/habit-tracker">
  </a>
</p>

# Habit Tracker (LevelUp Habits)

A clean, test-driven **habit tracker** with gamified streaks and XP — built with **Flutter**.  
This project is designed to showcase **clean code**, **tests with high coverage**, and a solid **CI/CD** pipeline.

> Package name in code: `levelup_habits` — Repository name: `habit-tracker`.

---

## ✨ Features

- Create, edit, delete daily habits
- One‑tap completion with undo
- Streaks, XP and stats (weekly / monthly)
- Local persistence (no backend) with import/export
- Optional daily reminder notifications (mobile)
- Theming (light/dark) and accessibility minded UI
- Fully covered with unit + widget tests

---

## 🚀 Live Demo

**Web:** https://rurfy.github.io/habit-tracker/

> Note: Browser notifications are disabled on web; you’ll see a friendly explanation instead.

---

## 🧱 Architecture

- **UI** (Flutter Widgets)
- **State** via **Provider**
- **Services** (Storage, Notifications) injected into providers
- **Models** (Habit, Settings) — JSON persisted
- **Utilities** (time/clock) to make logic deterministic in tests

See the full diagram and flow in [`docs/architecture.md`](docs/architecture.md).

---

## 📸 Screenshots

Add your screenshots under `docs/` and reference them here:

| Home | Stats | New Habit |
|---|---|---|
| ![Home](docs/screenshot_home.png) | ![Stats](docs/screenshot_stats.png) | ![New Habit](docs/screenshot_new.png) |

---

## 🛠️ Getting Started

Prereqs: Flutter stable

```bash
git clone https://github.com/rurfy/habit-tracker.git
cd habit-tracker/frontend
flutter pub get
flutter run  # choose Chrome, Android, or iOS simulator
```

---

## ✅ Quality Gates

- **Static analysis**: `flutter analyze` (0 warnings)
- **Formatting**: `dart format --set-exit-if-changed .`
- **Tests + coverage**: `flutter test --coverage` (Codecov gate ≥ 80%)
- **Strict lints**: see [`frontend/analysis_options.yaml`](frontend/analysis_options.yaml)

Run locally:

```bash
cd frontend
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
```

---

## 🧪 Tests

- **Unit tests**: models (streaks, XP), services (storage, notifications)
- **Widget tests**: primary screens + tiles (light/dark)
- **Deterministic time**: utilities allow freezing the clock in tests
- **Migration tests**: future‑proofing persisted data

```bash
cd frontend
flutter test --coverage
```

Coverage report is uploaded to Codecov on CI.

---

## 🔁 CI/CD

- **CI**: GitHub Actions runs analyze, format check, tests, and uploads coverage
- **Web deploy**: auto‑publishes to GitHub Pages after a green CI
- **Mobile releases**: separate workflows for Android/iOS builds
- **Coverage gate**: CI fails if overall coverage < 80%

See the workflows under [`.github/workflows`](.github/workflows).

---

## 🤝 Contributing

PRs welcome! Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) for setup, tooling, and commit style.

---

## 🗺️ Roadmap

- [ ] Golden tests for core screens
- [ ] Export/import polish & validation
- [ ] i18n scaffolding (EN/DE)
- [ ] PWA manifest + install prompt (web)

---

## 📜 License

MIT — see [`LICENSE`](LICENSE).

---

## 🙌 Credits

Built by **Christopher Richter** ([@rurfy](https://github.com/rurfy)).
