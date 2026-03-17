import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/player_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'playlists_screen.dart';
import 'settings_screen.dart';
import 'player_screen.dart';

class ShellScreen extends StatefulWidget {
  final ApiService api;
  final PlayerService player;
  final SettingsService settings;

  const ShellScreen({
    super.key,
    required this.api,
    required this.player,
    required this.settings,
  });

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _tab = 0;

  void _openPlayer() {
    if (widget.player.currentTrack == null) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => PlayerScreen(player: widget.player),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
          api: widget.api,
          player: widget.player,
          settings: widget.settings),
      PlaylistsScreen(api: widget.api, player: widget.player),
      SettingsScreen(settings: widget.settings, api: widget.api),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player sits above the nav bar
          StreamBuilder(
            stream: widget.player.playerStateStream,
            builder: (_, __) => widget.player.currentTrack != null
                ? MiniPlayer(player: widget.player, onTap: _openPlayer)
                : const SizedBox.shrink(),
          ),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            backgroundColor: AppTheme.surface,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppTheme.accent.withOpacity(0.2),
            labelBehavior:
                NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded,
                    color: AppTheme.accent),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.queue_music_outlined),
                selectedIcon: Icon(Icons.queue_music_rounded,
                    color: AppTheme.accent),
                label: 'Playlists',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon:
                    Icon(Icons.settings_rounded, color: AppTheme.accent),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
