FROM python:3.12 AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install  --no-cache-dir -r requirements.txt


FROM python:3.12-slim
ARG BUILD_ENV=prod \
ENV APP_ENV=${BUILD_ENV} \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
WORKDIR /app
RUN useradd -r -u 1001 appuser
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --chown=appuser:appuser . .
USER appuser

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/')" || exit 1
CMD [ "python" , "script_that_spawns_zombies.py" ] 



