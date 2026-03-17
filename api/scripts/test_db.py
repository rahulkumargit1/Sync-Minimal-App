import asyncpg
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

async def test_conn():
    url = os.getenv("DATABASE_URL")
    print(f"Testing connection to: {url}")
    try:
        conn = await asyncpg.connect(url)
        print("Connection successful!")
        await conn.close()
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    asyncio.run(test_conn())
