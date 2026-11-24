# ---------- Stage 1: build wheels (has compilers, thrown away later) ----------
FROM python:3.15-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# ---------- Stage 2: small runtime image ----------
FROM python:3.15-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Run as a non-root user (security best practice; flagged by image scanners otherwise)
RUN groupadd --system app && useradd --system --gid app --home /app app
WORKDIR /app

COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels

COPY --chown=app:app . .
USER app

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request,sys; urllib.request.urlopen('http://localhost:8000/api/health'); sys.exit(0)"

# Gunicorn manages multiple Uvicorn workers -> uses all vCPUs of the Fargate task
CMD ["sh", "-c", "gunicorn app.main:app -k uvicorn.workers.UvicornWorker -w ${WEB_CONCURRENCY:-2} -b 0.0.0.0:${PORT} --access-logfile -"]
