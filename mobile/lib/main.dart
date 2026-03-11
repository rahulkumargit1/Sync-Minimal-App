import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'views/library_view.dart';

void main() {
  // Ensure eager initialization for the core UI.
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const SyncApp());
}

class SyncApp extends StatelessWidget {
  const SyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sync',
      debugShowCheckedModeBanner: false,
      theme: SyncTheme.minimalistTheme,
      home: const LibraryView(),
    );
  }
}
