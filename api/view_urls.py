import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def main():
    database_url = os.getenv("DATABASE_URL")
    conn = await asyncpg.connect(database_url)
    rows = await conn.fetch('SELECT title, audio_url FROM tracks LIMIT 5')
    for r in rows:
        print(f"{r['title']} | {r['audio_url']}")
    await conn.close()

if __name__ == "__main__":
    asyncio.run(main())
