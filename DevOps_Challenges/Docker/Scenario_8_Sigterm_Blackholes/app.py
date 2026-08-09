import signal
import sys
import time

def handle_sigterm(signum, frame):
    print("Received SIGTERM, shutting down cleanly...", flush=True)
    sys.exit(0)

# 1. Register handler
signal.signal(signal.SIGTERM, handle_sigterm)

print("Running, will shut down cleanly on SIGTERM...", flush=True)

# 2. Single execution loop
while True:
    time.sleep(1)