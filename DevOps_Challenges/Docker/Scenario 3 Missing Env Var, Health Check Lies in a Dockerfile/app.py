from flask import Flask, jsonify
import os
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200  # shallow — always says yes

@app.route('/health')
def health():
    if 'DATABASE_URL' not in os.environ:
        return jsonify({"status": "unhealthy", "reason": "DATABASE_URL missing"}), 503
    return jsonify({"status": "healthy"}), 200