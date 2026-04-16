import os 
import json
from flask import Flask, jsonify

app = Flask(__name__)
DB_CONNECTION = None

def init_db():
    global DB_CONNECTION
    db_url = os.environ.get('DATABASE_URL')
    if db_url:
        DB_CONNECTION = {"url":db_url, "connected": True}
    else:
        DB_CONNECTION = None

@app.route('/health')
def health():
    return jsonify({"status":"ok"}), 200

@app.route('/api/users/')
def get_users():
    if not DB_CONNECTION:
        raise RuntimeError("Database not initialised")
    return jsonify({"users": ["alice", "bob"]}), 200

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000)