# Stage 1: Build dependencies
FROM python:3.12-slim-bullseye AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
RUN apt-get update && apt-get install -y gcc libpq-dev
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# Stage 2: Final Runtime
FROM python:3.12-slim-bullseye

WORKDIR /app
RUN apt-get update && apt-get install -y libpq5 netcat-traditional && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN groupadd -r django && useradd -r -g django django

COPY --from=builder /app/wheels /wheels
RUN pip install --no-cache /wheels/*

COPY --chown=django:django . .

USER django

# Expose port 8000 for Gunicorn
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "core.wsgi:application"]