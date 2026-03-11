import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'settings_view.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  // Mock data for initial scaffolding
  final List<String> _mockTracks = List.generate(50, (index) => 'Track ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
          ),
        ],
      ),
      // Use ListView.builder for high performance on 120Hz displays with large lists
      body: ListView.builder(
        itemCount: _mockTracks.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              color: SyncTheme.darkGrey,
              // Will be replaced with CachedNetworkImage
            ),
            title: Text(
              _mockTracks[index],
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Artist Name',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // Open Player
            },
          );
        },
      ),
    );
  }
}
