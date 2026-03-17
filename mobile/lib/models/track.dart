class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final int duration; // seconds
  final String audioUrl;
  final String coverUrl;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.duration,
    required this.audioUrl,
    required this.coverUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      genre: (json['genre'] as String?) ?? 'Unknown',
      duration: json['duration'] as int,
      audioUrl: json['audio_url'] as String,
      coverUrl: json['cover_url'] as String,
    );
  }

  String get formattedDuration {
    final m = duration ~/ 60;
    final s = duration % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
