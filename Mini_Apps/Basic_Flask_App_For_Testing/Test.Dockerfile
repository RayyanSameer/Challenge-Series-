FROM python:3.9-slim
WORKDIR .
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000

CMD ["python", "app.py"]

#FROM python:3.9-slim
#After baseimg , set working directory to current directory
#WORKDIR .
#Copy requirements.txt to the working directory
#COPY requirements.txt .
#Install dependencies from requirements.txt
#RUN pip install -r requirements.txt

#Expose port 5000 for the Flask app
#EXPOSE 5000

#Basically for every Dockerfile there are 7 main steps:
#1. Choose a base image (FROM)
#2. Set the working directory (WORKDIR)
#3. Copy necessary files (COPY) 
#4. Install dependencies (RUN)
#5. Copy the application code (COPY) (Layer Cachiing Tip: Combine with previous COPY if possible to reduce layers)
#6. Expose necessary ports (EXPOSE)
#7. Define the command to run the application (CMD)
