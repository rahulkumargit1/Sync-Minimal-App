import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cover_art.dart';

class PlayerScreen extends StatelessWidget {
  final PlayerService player;

  const PlayerScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final track = player.currentTrack;
    if (track == null) {
      Navigator.pop(context);
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing',
            style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceMuted)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.onSurfaceMuted),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Cover Art with glow
            Hero(
              tag: 'cover_${track.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.25),
                      blurRadius: 50,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CoverArt(
                  url: track.coverUrl,
                  size: MediaQuery.of(context).size.width - 56,
                  borderRadius: 24,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Track info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppTheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(track.artist,
                          style: const TextStyle(
                              color: AppTheme.onSurfaceMuted, fontSize: 15)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(track.genre,
                      style: const TextStyle(
                          color: AppTheme.accentLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Seek bar
            StreamBuilder<PositionData>(
              stream: player.positionDataStream,
              builder: (_, snap) {
                final data = snap.data ??
                    PositionData(Duration.zero, Duration.zero, Duration.zero);
                final total = data.duration.inMilliseconds.toDouble();
                final pos = data.position.inMilliseconds
                    .clamp(0, total > 0 ? total.toInt() : 0)
                    .toDouble();
                final buffered = data.buffered.inMilliseconds
                    .clamp(0, total > 0 ? total.toInt() : 0)
                    .toDouble();

                return Column(
                  children: [
                    Stack(
                      children: [
                        // Buffered bar
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: SliderComponentShape.noThumb,
                            activeTrackColor: AppTheme.divider.withOpacity(0.6),
                            inactiveTrackColor: AppTheme.divider,
                            overlayShape: SliderComponentShape.noOverlay,
                          ),
                          child: Slider(
                            value: total > 0 ? buffered / total : 0,
                            onChanged: null,
                          ),
                        ),
                        // Playback slider
                        Slider(
                          value: total > 0 ? (pos / total) : 0,
                          onChanged: total > 0
                              ? (v) => player
                                  .seek(Duration(milliseconds: (v * total).toInt()))
                              : null,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(data.position),
                              style: const TextStyle(
                                  color: AppTheme.onSurfaceMuted, fontSize: 12)),
                          Text(_fmt(data.duration),
                              style: const TextStyle(
                                  color: AppTheme.onSurfaceMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            // Controls
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (_, snap) {
                final state = snap.data;
                final playing = state?.playing ?? false;
                final loading = state?.processingState == ProcessingState.loading ||
                    state?.processingState == ProcessingState.buffering;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous
                    _ControlButton(
                      icon: Icons.skip_previous_rounded,
                      size: 36,
                      color: player.hasPrevious
                          ? AppTheme.onSurface
                          : AppTheme.onSurfaceMuted,
                      onTap: player.hasPrevious ? player.playPrevious : null,
                    ),
                    // Play/Pause
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accentLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.accent.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2),
                        ],
                      ),
                      child: loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : IconButton(
                              icon: Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                              onPressed: player.togglePlay,
                            ),
                    ),
                    // Next
                    _ControlButton(
                      icon: Icons.skip_next_rounded,
                      size: 36,
                      color: player.hasNext
                          ? AppTheme.onSurface
                          : AppTheme.onSurfaceMuted,
                      onTap: player.hasNext ? player.playNext : null,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            // Volume
            StreamBuilder<double>(
              stream: player.volumeStream,
              builder: (_, snap) {
                final vol = snap.data ?? 1.0;
                return Row(
                  children: [
                    Icon(vol == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded,
                        color: AppTheme.onSurfaceMuted, size: 20),
                    Expanded(
                      child: Slider(
                        value: vol,
                        onChanged: player.setVolume,
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded,
                        color: AppTheme.onSurfaceMuted, size: 20),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;

  const _ControlButton(
      {required this.icon,
      required this.size,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
