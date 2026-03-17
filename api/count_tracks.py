import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def main():
    database_url = os.getenv("DATABASE_URL")
    try:
        conn = await asyncpg.connect(database_url)
        res = await conn.fetchval('SELECT count(*) FROM tracks')
        print(f'TOTAL_TRACKS_IN_CLOUD: {res}')
        await conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
