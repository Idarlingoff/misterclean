import 'package:flutter/material.dart';

import 'cat_list_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heliosito'),
        actions: [
          IconButton(
              icon: const Icon(Icons.dark_mode),
              onPressed: () => _toggleDarkMode(context)),
          IconButton(
              icon: const Icon(Icons.cloud_sync),
              onPressed: () => _syncWithCloud(context)),
          IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () => _exportData(context)),
        ],
      ),
      body: const CatListPage(),
    );
  }

  //! 1.2.5. DRY
  //? Ces trois méthodes font exactement la même chose : afficher une SnackBar avec un texte "coming soon"
  //! 1.2.2. YAGNI 
  //? On a pas besoin de ces méthodes 
  void _toggleDarkMode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dark mode coming soon')));
  }

  void _syncWithCloud(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud sync coming soon')));
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Export coming soon')));
  }
}
