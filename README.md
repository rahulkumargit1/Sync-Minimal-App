# Sync — Minimal Music Streaming App

A Flutter + FastAPI music streaming app with PostgreSQL backend.

## Project Structure

```
sync-app/
├── api/                    # FastAPI backend
│   ├── main.py             # API server
│   ├── init.sql            # DB schema + seed data
│   ├── requirements.txt
│   ├── Dockerfile
│   └── scripts/
│       ├── upload_utility.py     # Upload MP3s to S3 + DB
│       └── update_local_urls.py  # Convert local paths → HTTP URLs
├── mobile/                 # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/         # Track, Playlist
│   │   ├── screens/        # Home, Playlists, Player, Settings, Shell
│   │   ├── services/       # API, Player, Settings
│   │   ├── theme/          # AppTheme (dark + light)
│   │   └── widgets/        # CoverArt, MiniPlayer
│   ├── android/
│   └── pubspec.yaml
└── docker-compose.yaml
```

## Quick Start

### 1. Start the backend
```bash
docker compose up -d
```
API will be available at `http://localhost:7860`

### 2. Run the Flutter app
```bash
cd mobile
flutter pub get
flutter run
```

### 3. Configure API URL in the app
- Open the **Settings** tab
- Set API Base URL:
  - Android Emulator: `http://10.0.2.2:7860`
  - Physical device: `http://<your-machine-ip>:7860`
  - Web/Desktop: `http://localhost:7860`
- Tap **Save** then **Check Server** to verify connection

## Environment Variables (api/.env)

```env
DATABASE_URL=postgresql://postgres:sync_pass@localhost:5444/sync_db
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
S3_BUCKET=your-bucket-name
SMALL_MP3_PATH=/path/to/small/mp3s   # optional, for local file serving
LARGE_MP3_PATH=/path/to/large/mp3s   # optional
```

## Uploading Music

```bash
cd api
# Upload MP3s from a folder to S3 and register in DB
python scripts/upload_utility.py /path/to/music --upload

# Convert local file paths in DB to HTTP URLs
BASE_URL=http://your-server:7860 python scripts/update_local_urls.py
```

## Features

- 🎵 Track library with search and genre filtering
- 📋 Playlists with mosaic cover art
- ▶️ Full-screen player with seek bar, volume, prev/next
- 🎚️ Mini player with live progress bar
- ⚙️ Settings: API URL, stream quality, theme, auto-play, cache
- 🌙 Dark/light/system theme
- 🔄 Pull-to-refresh, shimmer loading, error states with retry
