import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/playlist.dart';
import '../models/track.dart';
import '../services/api_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';
import 'player_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  final ApiService api;
  final PlayerService player;

  const PlaylistsScreen({
    super.key,
    required this.api,
    required this.player,
  });

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  List<Playlist> _playlists = [];
  List<Track> _allTracks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.api.getPlaylists(),
        widget.api.getTracks(limit: 200),
      ]);
      if (!mounted) return;
      setState(() {
        _playlists = results[0] as List<Playlist>;
        _allTracks = results[1] as List<Track>;
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

  List<Track> _tracksForPlaylist(Playlist pl) {
    return pl.trackIds
        .map((id) => _allTracks.where((t) => t.id == id).firstOrNull)
        .whereType<Track>()
        .toList();
  }

  Duration _totalDuration(List<Track> tracks) {
    final secs = tracks.fold(0, (sum, t) => sum + t.duration);
    return Duration(seconds: secs);
  }

  String _fmtDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }

  void _openPlaylist(Playlist pl) {
    final tracks = _tracksForPlaylist(pl);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PlaylistDetailScreen(
          playlist: pl,
          tracks: tracks,
          player: widget.player,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      body: _loading
          ? _buildShimmer()
          : _error != null
              ? _buildError()
              : _buildList(),
    );
  }

  Widget _buildList() {
    if (_playlists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.queue_music_rounded,
                color: AppTheme.onSurfaceMuted, size: 56),
            SizedBox(height: 12),
            Text('No playlists yet',
                style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _playlists.length,
        itemBuilder: (_, i) {
          final pl = _playlists[i];
          final tracks = _tracksForPlaylist(pl);
          return _PlaylistCard(
            playlist: pl,
            tracks: tracks,
            totalDuration: _fmtDuration(_totalDuration(tracks)),
            onTap: () => _openPlaylist(pl),
            onPlay: () async {
              if (tracks.isEmpty) return;
              try {
                await widget.player.playTrack(tracks.first, queue: tracks);
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(player: widget.player),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Playback error: $e'),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.surfaceVariant,
        highlightColor: AppTheme.divider,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppTheme.onSurfaceMuted, size: 56),
            const SizedBox(height: 16),
            const Text('Could not load playlists',
                style: TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 13)),
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
}

// ──────────────────────────────────────────────
// Playlist Card
// ──────────────────────────────────────────────

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final List<Track> tracks;
  final String totalDuration;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _PlaylistCard({
    required this.playlist,
    required this.tracks,
    required this.totalDuration,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Mosaic cover art (up to 4 images in 2x2 grid)
              _MosaicCover(tracks: tracks.take(4).toList()),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppTheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${tracks.length} track${tracks.length == 1 ? '' : 's'}'
                      '${tracks.isNotEmpty ? ' · $totalDuration' : ''}',
                      style: const TextStyle(
                          color: AppTheme.onSurfaceMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Play button
              if (tracks.isNotEmpty)
                GestureDetector(
                  onTap: onPlay,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.accent.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 24),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MosaicCover extends StatelessWidget {
  final List<Track> tracks;
  const _MosaicCover({required this.tracks});

  @override
  Widget build(BuildContext context) {
    if (tracks.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.queue_music_rounded,
            color: AppTheme.onSurfaceMuted, size: 28),
      );
    }
    if (tracks.length == 1) {
      return CoverArt(url: tracks[0].coverUrl, size: 60, borderRadius: 12);
    }
    // 2×2 grid mosaic
    final cells = [
      tracks[0].coverUrl,
      tracks.length > 1 ? tracks[1].coverUrl : tracks[0].coverUrl,
      tracks.length > 2 ? tracks[2].coverUrl : tracks[0].coverUrl,
      tracks.length > 3 ? tracks[3].coverUrl : tracks[0].coverUrl,
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        height: 60,
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          children: cells
              .map((url) => CoverArt(url: url, size: 29.5, borderRadius: 0))
              .toList(),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Playlist Detail Screen
// ──────────────────────────────────────────────

class _PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  final List<Track> tracks;
  final PlayerService player;

  const _PlaylistDetailScreen({
    required this.playlist,
    required this.tracks,
    required this.player,
  });

  @override
  State<_PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<_PlaylistDetailScreen> {
  Future<void> _playTrack(Track track) async {
    try {
      await widget.player.playTrack(track, queue: widget.tracks);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PlayerScreen(player: widget.player)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Playback error: $e'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        actions: [
          if (widget.tracks.isNotEmpty)
            TextButton.icon(
              onPressed: () => _playTrack(widget.tracks.first),
              icon: const Icon(Icons.play_arrow_rounded,
                  color: AppTheme.accent, size: 20),
              label: const Text('Play All',
                  style: TextStyle(color: AppTheme.accent)),
            ),
        ],
      ),
      body: widget.tracks.isEmpty
          ? const Center(
              child: Text('This playlist has no tracks',
                  style: TextStyle(color: AppTheme.onSurfaceMuted)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.tracks.length,
              itemBuilder: (_, i) {
                final track = widget.tracks[i];
                final isPlaying = widget.player.currentTrack?.id == track.id;
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
                    onTap: () => _playTrack(track),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${i + 1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isPlaying
                                  ? AppTheme.accent
                                  : AppTheme.onSurfaceMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CoverArt(
                            url: track.coverUrl, size: 46, borderRadius: 9),
                      ],
                    ),
                    title: Text(track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: isPlaying
                                ? AppTheme.accentLight
                                : AppTheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    subtitle: Text(track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppTheme.onSurfaceMuted, fontSize: 12)),
                    trailing: Text(track.formattedDuration,
                        style: const TextStyle(
                            color: AppTheme.onSurfaceMuted, fontSize: 12)),
                  ),
                );
              },
            ),
    );
  }
}
