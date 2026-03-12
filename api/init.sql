CREATE TABLE tracks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    album TEXT NOT NULL,
    genre TEXT,
    duration INTEGER NOT NULL,
    audio_url TEXT NOT NULL,
    cover_url TEXT NOT NULL
);

CREATE TABLE playlists (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    track_ids TEXT[]
);

-- Insert some mock data for testing
INSERT INTO tracks (id, title, artist, album, duration, audio_url, cover_url) VALUES
('t_1', 'Starlight Night', 'Luna Sky', 'Midnight Dreams', 210, 'https://s3.amazonaws.com/sync-app/audio1.mp3', 'https://s3.amazonaws.com/sync-app/cover1.jpg'),
('t_2', 'Ocean Breeze', 'Deep Blue', 'Elements', 195, 'https://s3.amazonaws.com/sync-app/audio2.mp3', 'https://s3.amazonaws.com/sync-app/cover2.jpg'),
('t_3', 'City Lights', 'Urban Echo', 'Vibe City', 240, 'https://s3.amazonaws.com/sync-app/audio3.mp3', 'https://s3.amazonaws.com/sync-app/cover3.jpg');

INSERT INTO playlists (id, name, track_ids) VALUES
('p_1', 'Morning Vibes', ARRAY['t_1', 't_2']),
('p_2', 'Work Focus', ARRAY['t_3']);
