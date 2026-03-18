import os
import json
import socket
import boto3
from dotenv import load_dotenv

load_dotenv()

S3_BUCKET = os.getenv("S3_BUCKET")

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

def update_s3():
    ip = get_ip()
    url = f"http://{ip}:8000"
    data = json.dumps({"url": url})
    
    with open("server.json", "w") as f:
        f.write(data)
        
    s3_client = boto3.client("s3")
    s3_client.upload_file("server.json", S3_BUCKET, "server.json", ExtraArgs={'ContentType': 'application/json'})
    print(f"Uploaded {url} to https://s3.amazonaws.com/{S3_BUCKET}/server.json")

if __name__ == "__main__":
    update_s3()
