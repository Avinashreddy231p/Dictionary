import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Appearance'),
            subtitle: Text('System default'),
          ),
          ListTile(
            leading: Icon(Icons.text_fields),
            title: Text('Text Size'),
            subtitle: Text('Medium'),
          ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Storage'),
            subtitle: Text('Manage offline dictionary'),
          ),
        ],
      ),
    );
  }
}
