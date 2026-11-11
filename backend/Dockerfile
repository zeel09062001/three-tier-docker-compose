# ---------------------------------------------------------------------------
# Backend image: Python + Flask, served by gunicorn
# ---------------------------------------------------------------------------

# 1. Start from an official, small Python image
FROM python:3.12-slim

# 2. Python settings suited to containers
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 3. All following commands run inside /app
WORKDIR /app

# 4. Install libraries FIRST (this layer is cached until requirements.txt changes)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Then copy the application code (changes often, so it comes last)
COPY app.py .

# 6. Create an ordinary user, and stop running as root
RUN useradd --create-home --uid 10001 appuser
USER appuser

# 7. Document the port the app listens on
EXPOSE 5000

# 8. Start gunicorn: 2 workers, listening on every network interface, port 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-", "app:app"]