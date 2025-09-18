// File: frontend/lib/main.dart
// App entry point: registers providers, initializes notifications, and builds a
// MaterialApp (light/dark) that waits for the initial load before showing Home.

import 'package:flutter/material.dart';
import 'package:levelup_habits/providers/settings_provider.dart';
import 'package:levelup_habits/services/notification_service.dart';
import 'package:levelup_habits/services/notifier.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService
      .init(); // no-op on web; prepares local notifications
  runApp(const LevelUpApp());
}

class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // App-wide state & services
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()), // habits domain
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // theme mode
        Provider<Notifier>(create: (_) => LocalNotifier()), // notifications
        ChangeNotifierProvider(
            create: (_) => SettingsProvider()), // user settings
      ],
      builder: (context, _) {
        final theme = context.watch<ThemeProvider>();

        return MaterialApp(
          title: 'LevelUp Habits',
          // Material 3 + seeded color scheme (light)
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          // Matching dark palette
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: theme.mode, // system/light/dark
          // Load initial state once; show a simple splash until ready
          home: FutureBuilder(
            future: context.read<HabitProvider>().loadInitial(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const HomeScreen();
            },
          ),
        );
      },
    );
  }
}
