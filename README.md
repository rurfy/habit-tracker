# 📈 LevelUp Habits

Ein moderner, plattformübergreifender Habit Tracker, der Nutzern hilft, Gewohnheiten zu entwickeln, Fortschritte zu verfolgen und motiviert zu bleiben – mit einem spielerischen XP- und Level-System.  
Erstellt mit **Flutter**, um sowohl auf **Web** als auch **Android** (und optional iOS) zu laufen.

---

## 🚀 Features

- **Gewohnheiten hinzufügen & verwalten** 📝  
- **Tägliche Check-ins** mit automatischer Streak-Berechnung 📅  
- **Gamification**: XP-System & Level-Aufstieg 🎮  
- **Dauerhafte Speicherung** dank `SharedPreferences` 💾  
- **Responsive Design** für Web & Mobile 📱💻  
- **Saubere Architektur** mit `Provider` State-Management  
- **Solide Tests**: Unit- & Widget-Tests integriert ✅

---

## 🛠️ Tech Stack

- **Frontend & Backend in einem**: [Flutter](https://flutter.dev)  
- **State Management**: Provider  
- **Local Storage**: SharedPreferences  
- **Testing**: `flutter_test` + `mockito`  

---

## 📷 Screenshots

*(Screenshots hier einfügen, wenn verfügbar)*  
![Demo Screenshot](docs/screenshot.png)

---

## 🧪 Tests

Das Projekt enthält **Unit Tests** und **Widget Tests**:
```bash
flutter test
```
Tests decken u.a. Streak-Berechnung, Level-Logik und UI Rendering ab.

## 📦 Installation & Start

1. Repo klonen
```bash
git clone https://github.com/rurfy/levelup-habits.git
cd levelup-habits
```
2. Abhängigkeiten installieren
```bash
flutter pub get
```
3. App starten
```bash
flutter run -d chrome   # Für Web
flutter run -d android  # Für Android
```
## 🎯 Roadmap

Export/Import von Gewohnheiten

Push Notifications (Erinnerungen)

Statistik-Ansicht mit Diagrammen

    Cloud-Sync

## 👨‍💻 Autor

Christopher Richter

    💼 Software Engineer

    🔗 GitHub

    ✉️ E-Mail

## 📜 Lizenz

MIT License – feel free to use & contribute!