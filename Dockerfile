# Use lightweight base image
FROM python:3.12-slim

# Prevent Python from writing pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Prevent buffering
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies (minimal)
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first (for caching)
COPY requirements.txt .

# Install dependencies (no cache)
RUN pip install --no-cache-dir -r requirements.txt

# Copy data files
COPY data/ ./data/

# Copy application files
COPY app.py .
COPY collaborative_filtering.py .
COPY content_based_filtering.py .
COPY hybrid_recommendations.py .
COPY data_cleaning.py .
COPY transform_filtered_data.py .

# Expose port
EXPOSE 8000

# Run app
CMD ["streamlit", "run", "app.py", "--server.port=8000", "--server.address=0.0.0.0"]