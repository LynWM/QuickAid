import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_aid_app/components/theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF890000),
        title: Text('SETTINGS', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),

      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text("Dark Mode"),
            trailing: Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (value) {
                themeNotifier.toggleTheme();
              },
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info),
            title: Text("About"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Quick Aid",
                applicationVersion: "1.0.0",
                applicationLegalese: "@ Quick Aid Team 2025",
              );
            },
          ),
        ],
      ),
    );
  }
}
