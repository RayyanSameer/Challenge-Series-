import subprocess
import time

for i in range(10):
    subprocess.Popen(["sleep", "2"])  # spawned, never waited on — becomes a zombie once it finishes

while True:
    time.sleep(1)  # main process stays alive forever, never reaps children