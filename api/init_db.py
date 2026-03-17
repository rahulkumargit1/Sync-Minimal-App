import asyncio
import asyncpg
import os
from dotenv import load_dotenv

load_dotenv()

async def main():
    database_url = os.getenv("DATABASE_URL")
    print(f"Connecting to: {database_url}")
    try:
        conn = await asyncpg.connect(database_url)
        with open("init.sql", "r") as f:
            schema = f.read()
        await conn.execute(schema)
        await conn.close()
        print("Database initialized successfully!")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
