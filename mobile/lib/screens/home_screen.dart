import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/track.dart';
import '../services/api_service.dart';
import '../services/player_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService api;
  final PlayerService player;
  final SettingsService settings;

  const HomeScreen({
    super.key,
    required this.api,
    required this.player,
    required this.settings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Track> _tracks = [];
  List<String> _genres = [];
  String? _selectedGenre;
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.api.getTracks(genre: _selectedGenre),
        widget.api.getGenres(),
      ]);
      if (!mounted) return;
      setState(() {
        _tracks = results[0] as List<Track>;
        _genres = results[1] as List<String>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _playTrack(Track track) async {
    try {
      await widget.player.playTrack(track, queue: _filteredTracks);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not play "${track.title}": $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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

  List<Track> get _filteredTracks {
    if (_searchQuery.isEmpty) return _tracks;
    final q = _searchQuery.toLowerCase();
    return _tracks
        .where((t) =>
            t.title.toLowerCase().contains(q) ||
            t.artist.toLowerCase().contains(q) ||
            t.album.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Sync'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.onSurface, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search tracks, artists, albums…',
                hintStyle: const TextStyle(
                    color: AppTheme.onSurfaceMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.onSurfaceMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppTheme.onSurfaceMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // Genre chips
          if (_genres.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _GenreChip(
                    label: 'All',
                    selected: _selectedGenre == null,
                    onTap: () {
                      setState(() => _selectedGenre = null);
                      _load();
                    },
                  ),
                  ..._genres.map((g) => _GenreChip(
                        label: g,
                        selected: _selectedGenre == g,
                        onTap: () {
                          setState(() => _selectedGenre = g);
                          _load();
                        },
                      )),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildShimmer();

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: AppTheme.onSurfaceMuted, size: 56),
              const SizedBox(height: 16),
              const Text('Could not reach server',
                  style: TextStyle(
                      color: AppTheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.onSurfaceMuted, fontSize: 13)),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
              ),
            ],
          ),
        ),
      );
    }

    final tracks = _filteredTracks;
    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_off_rounded,
                color: AppTheme.onSurfaceMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : 'No tracks found',
              style:
                  const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tracks.length,
        itemBuilder: (_, i) => _TrackTile(
          index: i,
          track: tracks[i],
          isPlaying: widget.player.currentTrack?.id == tracks[i].id,
          onTap: () => _playTrack(tracks[i]),
          onOpenPlayer: _openPlayer,
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.surfaceVariant,
        highlightColor: AppTheme.divider,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Track Tile
// ──────────────────────────────────────────────
class _TrackTile extends StatelessWidget {
  final int index;
  final Track track;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onOpenPlayer;

  const _TrackTile({
    required this.index,
    required this.track,
    required this.isPlaying,
    required this.onTap,
    required this.onOpenPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppTheme.accent.withOpacity(0.12)
            : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: isPlaying
            ? Border.all(color: AppTheme.accent.withOpacity(0.4))
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: isPlaying ? onOpenPlayer : onTap,
        leading: Hero(
          tag: 'cover_${track.id}',
          child: CoverArt(url: track.coverUrl, size: 50, borderRadius: 10),
        ),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isPlaying ? AppTheme.accentLight : AppTheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${track.artist} · ${track.album}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: AppTheme.onSurfaceMuted, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPlaying) const _PlayingIndicator(),
            const SizedBox(width: 6),
            Text(
              track.formattedDuration,
              style: const TextStyle(
                  color: AppTheme.onSurfaceMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayingIndicator extends StatefulWidget {
  const _PlayingIndicator();
  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: const Icon(Icons.equalizer_rounded,
          color: AppTheme.accent, size: 18),
    );
  }
}

// ──────────────────────────────────────────────
// Genre Chip
// ──────────────────────────────────────────────
class _GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenreChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: AppTheme.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.onSurfaceMuted,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
