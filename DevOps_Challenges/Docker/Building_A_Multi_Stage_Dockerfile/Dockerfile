FROM python:3.12 AS builder 
WORKDIR /build
COPY requirements.txt .
RUN pip install  --no-cache-dir --prefix=/install -r requirements.txt

# Second Stage 

FROM python:3.12-slim
ARG BUILD_ENV=prod
ENV APP_ENV=$BUILD_ENV \
    PATH="/usr/local/bin:$PATH" \
    PYTHONUNBUFFERED=1
COPY --from=builder /install /usr/local 
WORKDIR /app 

RUN useradd -r -u 1001 appuser
COPY --chown=appuser:appuser . .
USER appuser
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/')" || exit 1
CMD [ "python" , "app.py" ]   