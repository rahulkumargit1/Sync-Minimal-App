import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import 'cover_art.dart';

class MiniPlayer extends StatelessWidget {
  final PlayerService player;
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.player, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final track = player.currentTrack;
    if (track == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.surfaceVariant, Color(0xFF1E1E3A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Thin progress bar at the bottom of the card
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: StreamBuilder<PositionData>(
                  stream: player.positionDataStream,
                  builder: (_, snap) {
                    final data = snap.data;
                    final total = data?.duration.inMilliseconds ?? 1;
                    final pos = data?.position.inMilliseconds ?? 0;
                    final progress =
                        total > 0 ? (pos / total).clamp(0.0, 1.0) : 0.0;
                    return LinearProgressIndicator(
                      value: progress,
                      minHeight: 2.5,
                      color: AppTheme.accent,
                      backgroundColor: AppTheme.divider,
                    );
                  },
                ),
              ),
              // Content row
              Positioned.fill(
                bottom: 2.5,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    CoverArt(url: track.coverUrl, size: 48, borderRadius: 10),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Play/pause
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (_, snap) {
                        final state = snap.data;
                        final playing = state?.playing ?? false;
                        final loading =
                            state?.processingState == ProcessingState.loading ||
                                state?.processingState ==
                                    ProcessingState.buffering;
                        return IconButton(
                          onPressed: loading ? null : player.togglePlay,
                          icon: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppTheme.accent),
                                )
                              : Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: AppTheme.onSurface,
                                  size: 28,
                                ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed: player.hasNext ? player.playNext : null,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: player.hasNext
                            ? AppTheme.onSurface
                            : AppTheme.onSurfaceMuted,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
