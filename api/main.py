import os
import asyncpg
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from typing import List, Optional
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Sync API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:sync_pass@127.0.0.1:5444/sync_db")

# --- Static File Serving ---
# Mounting local music folders so the mobile app can stream directly from the PC.
if os.path.exists(r"E:\smallmp3"):
    app.mount("/music/small", StaticFiles(directory=r"E:\smallmp3"), name="small_music")
if os.path.exists(r"E:\mp3"):
    app.mount("/music/large", StaticFiles(directory=r"E:\mp3"), name="large_music")

# --- Database Connection Pool ---
async def get_db_pool():
    if not hasattr(app, "db_pool"):
        app.db_pool = await asyncpg.create_pool(DATABASE_URL)
    return app.db_pool

@app.on_event("startup")
async def startup():
    app.db_pool = await asyncpg.create_pool(DATABASE_URL)

@app.on_event("shutdown")
async def shutdown():
    await app.db_pool.close()

# Placeholder Models
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
    """
    Fetch metadata from PostgreSQL for tracks using pagination and optional genre filter.
    """
    try:
        async with app.db_pool.acquire() as connection:
            if genre:
                query = "SELECT id, title, artist, album, genre, duration, audio_url, cover_url FROM tracks WHERE genre = $1 LIMIT $2 OFFSET $3"
                rows = await connection.fetch(query, genre, limit, offset)
            else:
                query = "SELECT id, title, artist, album, genre, duration, audio_url, cover_url FROM tracks LIMIT $1 OFFSET $2"
                rows = await connection.fetch(query, limit, offset)
            return [Track(**dict(row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/genres")
async def get_genres():
    """
    List unique genres from the database.
    """
    try:
        async with app.db_pool.acquire() as connection:
            rows = await connection.fetch("SELECT DISTINCT genre FROM tracks WHERE genre IS NOT NULL")
            return [row['genre'] for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/playlists", response_model=List[Playlist])
async def get_playlists():
    """
    Fetch user playlists.
    """
    try:
        async with app.db_pool.acquire() as connection:
            rows = await connection.fetch("SELECT id, name, track_ids FROM playlists")
            return [Playlist(**dict(row)) for row in rows]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "ok"}
