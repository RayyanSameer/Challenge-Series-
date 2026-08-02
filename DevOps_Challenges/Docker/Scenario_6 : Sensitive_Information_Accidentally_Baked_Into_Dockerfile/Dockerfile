FROM python:3.12-slim
WORKDIR /app
RUN --mount=type=secret,id=my_token \
    TOKEN=$(cat /run/secrets/my_token) && \
    pip install "git+https://${TOKEN}@github.com/myorg/private-repo.git"

COPY . .
CMD ["python", "app.py"]
