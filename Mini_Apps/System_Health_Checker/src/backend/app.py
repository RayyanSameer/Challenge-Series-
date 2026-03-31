import psutil
import redis
import datetime
import json
import os
from flask import Flask, jsonify, render_template, send_from_directory


app = Flask(__name__, template_folder='../frontend', 
            static_folder='../frontend')

r = redis.Redis(host='redis', port=6379, decode_responses=True)

@app.route('/')
def index():
    """Serves the index.html file from the same folder."""
    return render_template('index.html')

@app.route('/metrics')
def metrics():
    """Captures and stores system metrics."""
    data = {
        'cpu': psutil.cpu_percent(interval=1),
        'memory': psutil.virtual_memory().percent,
        'disk': psutil.disk_usage('/').percent,
        'timestamp': datetime.datetime.now().isoformat()
    }
    r.lpush('metrics_history', json.dumps(data))
    r.ltrim('metrics_history', 0, 9)
    return jsonify(data)

@app.route('/history')
def history():
    """Returns the last 10 snapshots from Redis."""
    raw_data = r.lrange('metrics_history', 0, -1)
    history_list = [json.loads(x) for x in raw_data]
    return jsonify(history_list)

@app.route('/<path:path>')
def send_report(path):
    
    return send_from_directory('../frontend', path)


if __name__ == '__main__':
    
    app.run(host='0.0.0.0', port=5000, debug=True, use_reloader=False)