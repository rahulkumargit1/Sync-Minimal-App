import 'package:flutter/material.dart';
import '../core/theme.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  // Gesture down dismiss helper
  double _dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 0) {
          setState(() {
            _dragOffset += details.primaryDelta!;
          });
        }
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 100) {
          Navigator.pop(context);
        } else {
          setState(() {
            _dragOffset = 0;
          });
        }
      },
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Scaffold(
          backgroundColor: SyncTheme.oledBlack,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Top bar indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: SyncTheme.mutedGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Album Art Placeholder (Minimalist)
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: SyncTheme.darkGrey,
                      // Will integrate CachedNetworkImage
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Track Info
                  Text(
                    'Track Title',
                    style: Theme.of(context).textTheme.displaySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Artist Name',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SyncTheme.mutedGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const Spacer(),
                  
                  // Dynamic Progress Bar (Minimalist line)
                  _buildProgressBar(),
                  
                  const SizedBox(height: 32),
                  
                  // Playback Controls
                  _buildControls(),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
            activeTrackColor: SyncTheme.starkWhite,
            inactiveTrackColor: SyncTheme.mutedGrey.withOpacity(0.3),
            thumbColor: SyncTheme.starkWhite,
          ),
          child: Slider(
            value: 0.3,
            onChanged: (value) {},
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1:02', style: Theme.of(context).textTheme.labelSmall),
            Text('3:45', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.shuffle, size: 24, color: SyncTheme.mutedGrey),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 36),
          onPressed: () {},
        ),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: SyncTheme.starkWhite,
          ),
          child: IconButton(
            icon: const Icon(Icons.pause, size: 36, color: SyncTheme.oledBlack),
            onPressed: () {},
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, size: 36),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.repeat, size: 24, color: SyncTheme.mutedGrey),
          onPressed: () {},
        ),
      ],
    );
  }
}
