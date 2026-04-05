#FlaskApp that checks sysinfo into a web UI and Redis Chaching 
#Parts 
# 1. Import 
# 2. App Setup 
# 3. Routes ./history and ./fetch 
# 4. Run

#Part one of the 4 step app build


import json
import os
import psutil
import datetime
from flask import Flask, jsonify, render_template, send_from_directory

#The app container and the Redis client setup

app = Flask(__name__, template_folder='../frontend', static_folder='../frontend'
)

r = redis.Redis(host='localhost', port=6379, decode_responses=True)



#index route to serve the frontend
app.route('/')
def index():
    return render_template('index.html')
#metrics route to capture and store system metrics in Redis
app.route('/metrics')
def metrics():
    data = {
        'cpu': psutil.cpu_percent(interval=1),
        'memory':psutil.virtual_memory().percent,
        'disk': psutil.disk_usage('/').percent,
        'timestamp': datetime.datetime.now().isoformat()
    }

    #Push and trim for 10 entries in Redis

    r.lpush('metrics_history', json.dumps(data))
    r.ltrim('metrics_history', 0, 9)    
    return jsonify(data)

#history route to return the last 10 snapshots from Redis

app.route('/history')
def history():
    #Get last 10 entries from Redis

    raw_data = r.lrange('metrics_history', 0, -1)
    history_list = [json.loads(x) for x in raw_data]
    return jsonify(history_list)

app.route('/<path:path>')
#Serve static files from the frontend folder
def send_report(path):
    return send_from_directory('../frontend', path)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True, use_reloader=False)


#Parts 

#Import 
#App boilerplate 
#Redis client setup
#Index route to serve frontend just called route 
#Metrics route to capture and store system metrics in Redis

#Use psutil to get CPU, memory, and disk usage, along with a timestamp. Store this data in Redis using lpush and trim to keep only the last 10 entries.


#History route to return the last 10 snapshots from Redis
#Serve static files from the frontend folder

#From the raw data retrieved from Redis, we parse the JSON strings into Python history list and return them as a JSON response.

#if name == main to run the app on host


