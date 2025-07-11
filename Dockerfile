FROM python:3.9-slim

WORKDIR /app

# Install FOGIS API client from PyPI (version 0.5.3 with pipeline fixes)
RUN pip install --no-cache-dir fogis-api-client-timmyBird==0.5.3

# Install other dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY *.py .
COPY tests/ ./tests/

# Create logs directory
RUN mkdir -p /app/logs

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV LOG_DIR=/app/logs

# Expose ports for metrics and health check
EXPOSE 8000

# Run the script
CMD ["python", "match_list_change_detector.py"]
