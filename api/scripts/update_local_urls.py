import asyncpg
import asyncio
import os
import sys
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
# BASE_URL should be set to the server address accessible by your mobile device
BASE_URL = os.getenv("BASE_URL", "http://localhost:7860")


async def update_urls():
    if not DATABASE_URL:
        print("ERROR: DATABASE_URL environment variable is not set.")
        sys.exit(1)

    conn = await asyncpg.connect(DATABASE_URL)

    # Fetch all tracks
    tracks = await conn.fetch("SELECT id, title, audio_url FROM tracks")

    updated = 0
    for track in tracks:
        track_id = track["id"]
        audio_url = track["audio_url"]

        # Only convert local file paths to serveable static URLs
        if os.path.exists(audio_url) or (len(audio_url) > 1 and audio_url[1] == ":"):
            filename = os.path.basename(audio_url)
            audio_lower = audio_url.lower()
            if "smallmp3" in audio_lower:
                new_url = f"{BASE_URL}/music/small/{filename}"
            elif "mp3" in audio_lower:
                new_url = f"{BASE_URL}/music/large/{filename}"
            else:
                continue

            print(f"Updating '{track['title']}': {new_url}")
            await conn.execute(
                "UPDATE tracks SET audio_url = $1 WHERE id = $2",
                new_url,
                track_id,
            )
            updated += 1

    await conn.close()
    print(f"Done. {updated} URL(s) updated.")


if __name__ == "__main__":
    asyncio.run(update_urls())
