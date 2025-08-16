import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (_) => context.read<ThemeProvider>().toggle(),
          ),
          SwitchListTile(
            title: const Text('Tägliche Zusammenfassung (Reminder)'),
            subtitle: const Text('Abends eine Übersicht deiner Check-ins'),
            value: settings.dailySummaryEnabled,
            onChanged: (v) =>
                context.read<SettingsProvider>().setDailySummary(v),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Daten exportieren (JSON in Zwischenablage)'),
            onTap: () async {
              final json = context.read<HabitProvider>().exportJson();
              await Clipboard.setData(ClipboardData(text: json));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON kopiert')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Daten importieren (JSON einfügen)'),
            onTap: () async {
              final ctrl = TextEditingController();
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Import JSON'),
                  content: TextField(
                    controller: ctrl,
                    maxLines: 8,
                    decoration: const InputDecoration(
                        hintText: 'Füge hier dein JSON ein'),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Import')),
                  ],
                ),
              );
              if (!context.mounted) return;
              if (ok == true && ctrl.text.trim().isNotEmpty) {
                await context
                    .read<HabitProvider>()
                    .importJson(ctrl.text.trim());
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Import erfolgreich')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
