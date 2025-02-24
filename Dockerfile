# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.13.0a4
FROM python:${PYTHON_VERSION}-alpine3.19 AS base

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-privileged user for running the application
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Copy dependency file before installing to improve caching
COPY requirements.txt .

# Install dependencies without cache to ensure a clean environment
RUN python -m pip install --no-cache-dir -r requirements.txt

# Switch to the non-privileged user
USER appuser

# Copy the source code into the container
COPY counter-service.py .

# Expose the application port
EXPOSE 8080

# Run the application with Gunicorn (logs enabled)
CMD ["gunicorn", "counter-service:app", "--bind", "0.0.0.0:8080", "--access-logfile", "-", "--error-logfile", "-"]

