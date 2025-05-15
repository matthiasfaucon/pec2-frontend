import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class SettingPreferences extends StatefulWidget {
  @override
  _SettingPreferencesState createState() => _SettingPreferencesState();
}

class _SettingPreferencesState extends State<SettingPreferences> {
  bool _isDarkMode = false;
  bool _commentsEnabled = true;
  bool _privateMessagesEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _isDarkMode = savedThemeMode == AdaptiveThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Préférences")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Apparence",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Mode sombre"),
            subtitle: const Text("Activer/désactiver le thème sombre"),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
              if (value) {
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            },
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: _isDarkMode ? Colors.amber : Colors.blueGrey,
            ),
          ),
          Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Confidentialité",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text("Commentaires"),
            subtitle: const Text(
              "Autoriser les commentaires sur vos publications",
            ),
            value: _commentsEnabled,
            onChanged: (bool value) {
              setState(() {
                _commentsEnabled = value;
              });
              // TODO: Implémenter la logique pour activer/désactiver les commentaires
            },
            secondary: Icon(
              Icons.comment,
              color: _commentsEnabled ? Colors.green : Colors.grey,
            ),
          ),
          SwitchListTile(
            title: const Text("Messages privés"),
            subtitle: const Text("Autoriser les messages privés"),
            value: _privateMessagesEnabled,
            onChanged: (bool value) {
              setState(() {
                _privateMessagesEnabled = value;
              });
              // TODO: Implémenter la logique pour activer/désactiver les messages privés
            },
            secondary: Icon(
              Icons.message,
              color: _privateMessagesEnabled ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
