# Docker Day 3 - Multi-Stage Dockerfile + Compose Orchestration

Built a multi-stage Dockerfile and a two-service Docker Compose stack (Flask + Redis), verified size optimization and startup ordering with real measurements.

## Multi-Stage Dockerfile

FROM python:3.12 AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
ARG BUILD_ENV=prod
ENV APP_ENV=$BUILD_ENV PATH="/usr/local/bin:$PATH"
COPY --from=builder /install /usr/local
WORKDIR /app
RUN useradd -r -u 1001 appuser
COPY --chown=appuser:appuser . .
USER appuser
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/')" || exit 1
CMD ["python", "app.py"]

### Verified results
- Final image size confirmed via docker image inspect --format='{{.Size}}' -> 88,754,077 bytes (~88.75MB). Under the <200MB target.
- Non-root confirmed: process runs as appuser (UID 1001), not root.
- Layer breakdown (docker history): only sizable layers are the dependency install (~168MB in builder stage, not carried into final image) and the python:3.12-slim base (~87MB).
- .dockerignore confirmed active - build context grew from 2B to 34B once populated.

### Key correction made during build
First attempt used python:3.12 (full image) for the final stage instead of -slim, which would have defeated the purpose of the multi-stage split. Corrected to -slim before final verification.

## Docker Compose - Two-Service Stack

services:
  web:
    stdin_open: true
    tty: true
    build: .
    ports:
      - "5000:5000"
    depends_on:
      redis:
        condition: service_healthy
    networks:
      - appnet
  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    volumes:
      - redis_data:/data
    networks:
      - appnet
volumes:
  redis_data:
networks:
  appnet:
    driver: bridge

### Verified behavior
- redis starts, passes healthcheck, transitions to Healthy
- web does not start until redis is confirmed healthy - depends_on: condition: service_healthy verified in real startup log ordering
- Graceful shutdown confirmed: SIGTERM triggers Redis RDB save before clean exit

## Issues Hit and Fixed

1. Final image not actually slim - used full python:3.12 in final stage instead of -slim - corrected base image
2. Instruction order confusion - did not understand dependency chain between Dockerfile lines - rule: each instruction can only rely on what prior instructions set up
3. Missing ARG/ENV/USER - multi-stage draft skipped build-time vars and non-root user - added ARG BUILD_ENV, ENV APP_ENV, useradd + USER appuser
4. Ownership mismatch risk - COPY ran as root before USER was set, no --chown - reordered to useradd then COPY --chown then USER
5. App crashed with EOFError - test app used input(), but docker compose up runs detached with no stdin - added stdin_open/tty to web service
6. Ambiguous image size reading - docker images showed two size columns, unclear which was accurate - cross-checked with docker image inspect --format, confirmed 88.8MB is real size
7. ports mapping dropped mid-edit - overwrote working config while adding new fields - habit now: re-read entire file after any edit

## Takeaways

- Multi-stage builds only pay off if the final stage, not just the builder, uses the minimal base image.
- docker images size output can be ambiguous when layers are shared; docker image inspect --format='{{.Size}}' is the authoritative number.
- depends_on alone does not guarantee readiness - only condition: service_healthy paired with a real healthcheck does.
- Containers should be designed for unattended execution; anything requiring live terminal interaction needs explicit stdin_open/tty support or redesign.