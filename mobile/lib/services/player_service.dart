import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/track.dart';

class PositionData {
  final Duration position;
  final Duration buffered;
  final Duration duration;

  const PositionData(this.position, this.buffered, this.duration);
}

class PlayerService {
  final AudioPlayer _player = AudioPlayer();
  final AudioHandler? _audioHandler;

  Track? _currentTrack;
  List<Track> _queue = [];
  int _queueIndex = -1;

  PlayerService({AudioHandler? audioHandler}) : _audioHandler = audioHandler;

  Track? get currentTrack => _currentTrack;
  List<Track> get queue => List.unmodifiable(_queue);
  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<double> get volumeStream => _player.volumeStream;

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, buffered, duration) =>
            PositionData(position, buffered, duration ?? Duration.zero),
      );

  bool get hasPrevious => _queueIndex > 0;
  bool get hasNext => _queueIndex < _queue.length - 1;

  Future<void> playTrack(Track track, {List<Track>? queue}) async {
    _currentTrack = track;
    if (queue != null) {
      _queue = queue;
      _queueIndex = queue.indexWhere((t) => t.id == track.id);
    }

    try {
      // Use the audio handler if available (for background audio support)
      if (_audioHandler != null) {
        final mediaItem = MediaItem(
          id: track.id,
          title: track.title,
          artist: track.artist,
          album: track.album,
          duration: Duration(seconds: track.duration),
          extras: {'url': track.audioUrl},
        );
        await _audioHandler!.playMediaItem(mediaItem);
      } else {
        // Fallback - directly play URL
        await _player.setUrl(track.audioUrl);
        await _player.play();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> playNext() async {
    if (!hasNext) return;
    _queueIndex++;
    await playTrack(_queue[_queueIndex], queue: _queue);
  }

  Future<void> playPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (!hasPrevious) return;
    _queueIndex--;
    await playTrack(_queue[_queueIndex], queue: _queue);
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  void dispose() => _player.dispose();
}
