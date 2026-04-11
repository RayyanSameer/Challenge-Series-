FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
gcc \
python3-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r ./requirements.txt

EXPOSE 5000

CMD ["python", "backend/app.py"]

#Break 1: Wrong port (EXPOSE 9999 but app runs on 5000)
#Break 2: Missing dependency in requirements.txt
#Break 3: Wrong CMD syntax