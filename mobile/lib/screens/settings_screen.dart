import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settings;
  final ApiService api;

  const SettingsScreen({super.key, required this.settings, required this.api});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _urlController;
  bool _checkingHealth = false;
  bool? _serverOnline;

  @override
  void initState() {
    super.initState();
    _urlController =
        TextEditingController(text: widget.settings.apiBaseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkServer() async {
    setState(() {
      _checkingHealth = true;
      _serverOnline = null;
    });
    final ok = await widget.api.checkHealth();
    setState(() {
      _checkingHealth = false;
      _serverOnline = ok;
    });
  }

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    await widget.settings.setApiBaseUrl(url);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API URL saved'),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
    await _checkServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Server'),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('API Base URL',
                    style: TextStyle(
                        color: AppTheme.onSurfaceMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        style: const TextStyle(
                            color: AppTheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'http://172.27.252.95:8000',
                          hintStyle: const TextStyle(
                              color: AppTheme.onSurfaceMuted, fontSize: 14),
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        onSubmitted: (_) => _saveUrl(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      onPressed: _saveUrl,
                      child: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Server status
                Row(
                  children: [
                    _checkingHealth
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.accent))
                        : Icon(
                            _serverOnline == null
                                ? Icons.circle_outlined
                                : _serverOnline!
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                            size: 14,
                            color: _serverOnline == null
                                ? AppTheme.onSurfaceMuted
                                : _serverOnline!
                                    ? Colors.greenAccent
                                    : AppTheme.error,
                          ),
                    const SizedBox(width: 6),
                    Text(
                      _checkingHealth
                          ? 'Checking…'
                          : _serverOnline == null
                              ? 'Tap Check Server to test connection'
                              : _serverOnline!
                                  ? 'Server is online'
                                  : 'Server unreachable',
                      style: const TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 12),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _checkingHealth ? null : _checkServer,
                      child: const Text('Check Server',
                          style: TextStyle(
                              color: AppTheme.accent, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _SectionHeader('Playback'),
          _Card(
            child: Column(
              children: [
                _DropdownTile<String>(
                  icon: Icons.hd_rounded,
                  label: 'Stream Quality',
                  value: widget.settings.streamQuality,
                  items: const [
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                  ],
                  onChanged: (v) async {
                    await widget.settings.setStreamQuality(v!);
                    setState(() {});
                  },
                ),
                const Divider(),
                _SwitchTile(
                  icon: Icons.skip_next_rounded,
                  label: 'Auto-play Next Track',
                  subtitle: 'Continue to next song automatically',
                  value: widget.settings.autoPlay,
                  onChanged: (v) async {
                    await widget.settings.setAutoPlay(v);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _SectionHeader('Appearance'),
          _Card(
            child: _DropdownTile<String>(
              icon: Icons.palette_rounded,
              label: 'Theme',
              value: widget.settings.themeMode,
              items: const [
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (v) async {
                await widget.settings.setThemeMode(v!);
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 16),
          _SectionHeader('Storage'),
          _Card(
            child: _SwitchTile(
              icon: Icons.download_rounded,
              label: 'Enable Offline Cache',
              subtitle: 'Save tracks for offline playback',
              value: widget.settings.cacheEnabled,
              onChanged: (v) async {
                await widget.settings.setCacheEnabled(v);
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Sync v1.0.0',
              style: const TextStyle(
                  color: AppTheme.onSurfaceMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2)),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppTheme.onSurfaceMuted, fontSize: 12)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: AppTheme.surface,
            style: const TextStyle(
                color: AppTheme.onSurface, fontSize: 14),
            icon: const Icon(Icons.expand_more_rounded,
                color: AppTheme.onSurfaceMuted, size: 18),
          ),
        ),
      ],
    );
  }
}
