import asyncpg
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
BASE_URL = "http://10.37.141.95:8000" # Updated for physical mobile device testing

async def update_urls():
    conn = await asyncpg.connect(DATABASE_URL)
    
    # Fetch all tracks
    tracks = await conn.fetch("SELECT id, title, audio_url FROM tracks")
    
    for track in tracks:
        track_id = track['id']
        audio_url = track['audio_url']
        
        # If the URL is a local path, convert it to a serveable static URL
        if os.path.exists(audio_url) or ":" in audio_url:
            filename = os.path.basename(audio_url)
            if "smallmp3" in audio_url.lower():
                new_url = f"{BASE_URL}/music/small/{filename}"
            elif "mp3" in audio_url.lower() and "smallmp3" not in audio_url.lower():
                new_url = f"{BASE_URL}/music/large/{filename}"
            else:
                continue
                
            print(f"Updating {track['title']}: {new_url}")
            await conn.execute(
                "UPDATE tracks SET audio_url = $1 WHERE id = $2",
                new_url, track_id
            )
            
    await conn.close()
    print("URLs updated successfully.")

if __name__ == "__main__":
    asyncio.run(update_urls())
