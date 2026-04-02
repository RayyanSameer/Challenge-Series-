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
import jsonify from