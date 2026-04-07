#This is a multi stage Dockerfile. The first stage is used to build the application, and the second stage is used to create a smaller image that only contains the necessary files to run the application.

#Stage 1: Build the application




FROM python:3.11 AS builder
WORKDIR /
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

#Stage 2 :  The smaller one 

FROM python:3.11-slim
WORKDIR /
COPY --from=builder /install /usr/local
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
