from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from pydantic import BaseModel

app = FastAPI(title="Sync API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Placeholder Models
class Track(BaseModel):
    id: str
    title: str
    artist: str
    album: str
    duration: int
    audio_url: str
    cover_url: str

class Playlist(BaseModel):
    id: str
    name: str
    track_ids: List[str]

# --- Endpoints ---

@app.get("/tracks", response_model=List[Track])
async def get_tracks(limit: int = 50, offset: int = 0):
    """
    Fetch metadata from PostgreSQL for 2,000+ tracks using pagination.
    """
    # TODO: Implement actual asyncpg database query
    mock_data = [
        Track(
            id=f"t_{i}",
            title=f"Track Title {i}",
            artist="Artist Name",
            album="Album Name",
            duration=225,
            audio_url="https://s3.amazonaws.com/your-bucket/audio.mp3",
            cover_url="https://s3.amazonaws.com/your-bucket/cover.jpg"
        )
        for i in range(offset, offset + limit)
    ]
    return mock_data

@app.get("/playlists", response_model=List[Playlist])
async def get_playlists():
    """
    Fetch user playlists.
    """
    return [
        Playlist(id="p_1", name="Favorites", track_ids=["t_1", "t_2"]),
    ]

@app.get("/health")
async def health_check():
    return {"status": "ok"}
