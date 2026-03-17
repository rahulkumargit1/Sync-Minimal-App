import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/settings_service.dart';
import 'services/api_service.dart';
import 'services/player_service.dart';
import 'screens/shell_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final settings = await SettingsService.create();
  final api = ApiService(settings);
  final player = PlayerService();

  runApp(SyncApp(settings: settings, api: api, player: player));
}

class SyncApp extends StatefulWidget {
  final SettingsService settings;
  final ApiService api;
  final PlayerService player;

  const SyncApp({
    super.key,
    required this.settings,
    required this.api,
    required this.player,
  });

  @override
  State<SyncApp> createState() => _SyncAppState();
}

class _SyncAppState extends State<SyncApp> {
  @override
  void dispose() {
    widget.player.dispose();
    super.dispose();
  }

  ThemeMode _resolveTheme(String mode) => switch (mode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _resolveTheme(widget.settings.themeMode),
      home: ShellScreen(
        api: widget.api,
        player: widget.player,
        settings: widget.settings,
      ),
    );
  }
}
