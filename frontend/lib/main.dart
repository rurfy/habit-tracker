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
  await NotificationService.init();
  runApp(const LevelUpApp());
}

class LevelUpApp extends StatelessWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<Notifier>(create: (_) => LocalNotifier()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      builder: (context, _) {
        final theme = context.watch<ThemeProvider>();
        return MaterialApp(
          title: 'LevelUp Habits',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: theme.mode,
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
