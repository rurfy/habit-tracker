# Architecture

```mermaid
flowchart TD
  subgraph UI[Flutter UI]
    Home[Home Screen]
    Stats[Stats Screen]
    NewHabit[New Habit Screen]
    Settings[Settings Screen]
  end

  subgraph State[State (Provider)]
    HP[HabitProvider]
    SP[SettingsProvider]
    TP[ThemeProvider]
  end

  subgraph Services[Services]
    Store[StorageService (SharedPreferences)]
    Notify[Notifier -> LocalNotifications]
    Clock[Clock (Time utils)]
  end

  subgraph Models[Models]
    Habit[Habit]
    Settings[Settings]
  end

  Home --> HP
  Stats --> HP
  NewHabit --> HP
  Settings --> SP
  Settings --> TP

  HP <--> Store
  HP --> Notify
  HP --> Habit
  SP <--> Store
  SP --> Settings

  classDef svc fill:#eef,stroke:#99f;
  class Store,Notify,Clock svc;
```

## Data Flow (Happy Path)

1. User toggles a habit in **Home**.
2. `HabitProvider` updates the in‑memory model and persists to `StorageService`.
3. Streak/XP are recalculated using `Clock` (deterministic in tests).
4. If relevant, a daily reminder is (re)scheduled via `Notifier`.
5. **Stats** screen subscribes to provider and re-renders.

## Testing Strategy

- Providers are tested with fake `Store`, fake `Notifier`, and a fixed `Clock`.
- Widget tests cover all screens in light/dark modes and empty states.
- Migration tests ensure old JSON can be read after schema changes.
