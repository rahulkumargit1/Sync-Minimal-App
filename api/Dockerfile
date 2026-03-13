# Create user with UID 1000
RUN useradd -m -u 1000 user

WORKDIR /app

# Install system dependencies for asyncpg/postgresql
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=user:user requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

COPY --chown=user:user . .

# Set environment path for the non-root user
ENV PATH="/home/user/.local/bin:${PATH}"

# Hugging Face Spaces expects port 7860
EXPOSE 7860

# Start uvicorn on port 7860
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
