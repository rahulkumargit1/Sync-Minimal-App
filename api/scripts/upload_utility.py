import os
import uuid
import boto3
import asyncpg
import asyncio
from mutagen.mp3 import MP3
from mutagen.id3 import ID3, TIT2, TPE1, TALB, TCON
from dotenv import load_dotenv

load_dotenv()

# Configuration
S3_BUCKET = os.getenv("S3_BUCKET")
DATABASE_URL = os.getenv("DATABASE_URL")
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
AWS_SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")

s3_client = boto3.client('s3')

def get_metadata(file_path):
    """Extract metadata from an MP3 file."""
    audio = MP3(file_path, ID3=ID3)
    duration = int(audio.info.length)
    
    tags = audio.tags
    title = str(tags.get('TIT2', os.path.basename(file_path)))
    artist = str(tags.get('TPE1', 'Unknown Artist'))
    album = str(tags.get('TALB', 'Unknown Album'))
    genre = str(tags.get('TCON', 'Unknown'))
    
    return {
        "title": title,
        "artist": artist,
        "album": album,
        "genre": genre,
        "duration": duration
    }

async def upload_file_to_s3(file_path, bucket_name, object_name):
    """Upload a file to S3 if it doesn't exist."""
    try:
        # Check if file exists in S3
        try:
            s3_client.head_object(Bucket=bucket_name, Key=object_name)
            print(f"File already exists in S3: {object_name}")
            return f"https://{bucket_name}.s3.amazonaws.com/{object_name}"
        except:
            pass
            
        s3_client.upload_file(file_path, bucket_name, object_name)
        return f"https://{bucket_name}.s3.amazonaws.com/{object_name}"
    except Exception as e:
        print(f"Error uploading to S3: {e}")
        return None

async def process_folder(folder_path, upload_to_s3=False):
    """Process all MP3 files in a folder and update the database."""
    conn = None
    try:
        conn = await asyncpg.connect(DATABASE_URL)
        print("Connected to database successfully.")
    except Exception as e:
        print(f"DATABASE CONNECTION ERROR: {e}")
        print("Continuing with S3 uploads ONLY. Media metadata will not be saved to DB yet.")
    
    for filename in os.listdir(folder_path):
        if filename.endswith(".mp3"):
            file_path = os.path.join(folder_path, filename)
            print(f"--- Processing: {filename} ---")
            
            metadata = get_metadata(file_path)
            track_id = str(uuid.uuid4())
            
            audio_url = file_path # Default to local path
            if upload_to_s3:
                s3_key = f"tracks/{track_id}.mp3"
                print(f"Uploading to S3: {S3_BUCKET}/{s3_key}")
                uploaded_url = await upload_file_to_s3(file_path, S3_BUCKET, s3_key)
                if uploaded_url:
                    audio_url = uploaded_url
                    print(f"S3 URL: {audio_url}")
                else:
                    print(f"Failed to upload {filename}")
            
            # Insert into database if available
            if conn:
                try:
                    await conn.execute(
                        """
                        INSERT INTO tracks (id, title, artist, album, genre, duration, audio_url, cover_url)
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                        ON CONFLICT (id) DO NOTHING
                        """,
                        track_id, metadata['title'], metadata['artist'], metadata['album'], 
                        metadata['genre'], metadata['duration'], audio_url, "https://placeholder.com/cover.jpg"
                    )
                    print(f"Added to database: {metadata['title']}")
                except Exception as e:
                    print(f"Failed to insert into DB: {e}")
            else:
                print(f"Database unavailable - Metadata for {metadata['title']} not saved.")
            
    if conn:
        await conn.close()

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python upload_utility.py <folder_path> [--upload]")
        sys.exit(1)
        
    folder = sys.argv[1]
    do_upload = "--upload" in sys.argv
    asyncio.run(process_folder(folder, upload_to_s3=do_upload))
