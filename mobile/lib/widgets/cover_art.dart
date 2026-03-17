import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class CoverArt extends StatelessWidget {
  final String url;
  final double size;
  final double borderRadius;

  const CoverArt({
    super.key,
    required this.url,
    this.size = 56,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: AppTheme.surfaceVariant,
          highlightColor: AppTheme.divider,
          child: Container(
            width: size,
            height: size,
            color: AppTheme.surfaceVariant,
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.accent.withOpacity(0.3), AppTheme.surfaceVariant],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(Icons.music_note_rounded,
              color: AppTheme.accent, size: size * 0.4),
        ),
      ),
    );
  }
}
