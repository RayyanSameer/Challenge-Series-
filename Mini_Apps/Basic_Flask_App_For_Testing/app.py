# app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Docker"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

    #This app is essentially my crash test dummy for testing out docker and kubernetes. It's a very basic flask app that just returns a string when you hit the root endpoint. The main point of this app is to have something simple to deploy and test with, so I can focus on learning the deployment process without worrying about the complexity of the application itself.