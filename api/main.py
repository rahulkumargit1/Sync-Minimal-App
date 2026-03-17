import os
import asyncpg
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from typing import List, Optional
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:sync_pass@127.0.0.1:5444/sync_db")

# Music folder paths are configurable via environment variables (cross-platform)
small_mp3_path = os.getenv("SMALL_MP3_PATH", "")
large_mp3_path = os.getenv("LARGE_MP3_PATH", "")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage database connection pool lifecycle."""
    app.db_pool = await asyncpg.create_pool(DATABASE_URL)
    yield
    await app.db_pool.close()


app = FastAPI(title="Sync API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount local music folders only if paths are configured and exist
if small_mp3_path and os.path.exists(small_mp3_path):
    app.mount("/music/small", StaticFiles(directory=small_mp3_path), name="small_music")
if large_mp3_path and os.path.exists(large_mp3_path):
    app.mount("/music/large", StaticFiles(directory=large_mp3_path), name="large_music")


# --- Models ---
class Track(BaseModel):
    id: str
    title: str
    artist: str
    album: str
    genre: Optional[str] = "Unknown"
    duration: int
    audio_url: str
    cover_url: str


class Playlist(BaseModel):
    id: str
    name: str
    track_ids: List[str]


# --- Endpoints ---

@app.get("/tracks", response_model=List[Track])
async def get_tracks(limit: int = 50, offset: int = 0, genre: Optional[str] = None):
    """Fetch track metadata with pagination and optional genre filter."""
    try:
        async with app.db_pool.acquire() as connection:
            if genre:
                query = (
                    "SELECT id, title, artist, album, genre, duration, audio_url, cover_url "
                    "FROM tracks WHERE genre = $1 LIMIT $2 OFFSET $3"
                )
                rows = await connection.fetch(query, genre, limit, offset)
            else:
                query = (
                    "SELECT id, title, artist, album, genre, duration, audio_url, cover_url "
                    "FROM tracks LIMIT $1 OFFSET $2"
                )
                rows = await connection.fetch(query, limit, offset)
            return [Track(**dict(row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/genres")
async def get_genres():
    """List unique genres from the database."""
    try:
        async with app.db_pool.acquire() as connection:
            rows = await connection.fetch(
                "SELECT DISTINCT genre FROM tracks WHERE genre IS NOT NULL"
            )
            return [row["genre"] for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/playlists", response_model=List[Playlist])
async def get_playlists():
    """Fetch user playlists."""
    try:
        async with app.db_pool.acquire() as connection:
            rows = await connection.fetch("SELECT id, name, track_ids FROM playlists")
            return [Playlist(**dict(row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
async def health_check():
    return {"status": "ok"}
