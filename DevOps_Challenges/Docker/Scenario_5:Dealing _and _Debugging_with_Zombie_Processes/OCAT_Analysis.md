
## The Actual Scenario - OCAT

### Observe
First real run of script_that_spawns_zombies.py exited immediately with code 0, no logs, and
an empty docker inspect output. docker top could not be run because the container was already
dead by the time the command executed.

### The Debugging Wall
Spent roughly an hour treating this as an unsolvable case - three passes through the standard
debug workflow (ps -a, logs, inspect/entrypoint) all came back with nothing to work from.

### What Was Actually Wrong (not a workflow failure)
The debug workflow was correct at every step - it accurately reported "clean exit, nothing to
report." The real problem was the reproduction script itself: workers were spawned and finished
in a fraction of a second, and while the parent stayed alive in a sleep loop, the container
should have kept running - meaning the true issue was elsewhere in this specific run (build
succeeding but process exiting), and the fix was to rebuild the reproduction so zombies would
be observable *while the container was still alive*, using short-lived spawned subprocesses
inside an infinite parent loop:

    import subprocess
    import time
    for i in range(10):
        subprocess.Popen(["sleep", "2"])  # spawned, never waited on - becomes a zombie once it finishes
    while True:
        time.sleep(1)  # main process stays alive forever, never reaps children

### Correlate (with the fixed reproduction)

    docker top zombie_test

Confirmed the container was alive and the main python process was running as PID 1.

### Analyse
Watched with `watch -n 1 "docker top zombie_test"` and confirmed zombie/defunct entries
accumulating over time as each spawned `sleep 2` finished and was never reaped.

### Test / Fix

    docker run -d --rm --init --name zombie_test zombie

Output now showed `/sbin/docker-init` as PID 1, wrapping the python process:

    1001   185288  ...  /sbin/docker-init -- python script_that_spawns_zombies.py
    1001   185326  ...  python script_that_spawns_zombies.py

No zombie or defunct entries appeared after this - docker-init reaped finished children
immediately.

### Alternative Fix (also validated)

    RUN apt-get update && apt-get install -y tini
    ENTRYPOINT ["/usr/bin/tini", "--"]
    CMD ["python", "-u", "script_that_spawns_zombies.py"]

## Root Cause

Zombie processes occur when a child exits but its parent never calls wait() (or equivalent) to
read its exit status. Application runtimes like Python or Node do not act as full init systems
when run directly as PID 1, so they never perform this reaping - the responsibility has to be
handled explicitly.

## Fix Summary

Use a real init system at PID 1: `docker run --init` (uses Docker's built-in docker-init/tini),
or install `tini` directly in the image and set it as ENTRYPOINT. Alternatively, handle
SIGCHLD / call .wait() explicitly in application code, though the init-system fix is simpler
and more robust.

## Failure Points and How to Improve

1. Build errors treated as one-off fixes rather than diagnosed by layer.
   Four separate build failures (--prefix issue, USER/COPY ordering, ARG/ENV chaining, typos)
   were each fixed individually as they appeared, without stepping back to ask "what layer is
   each of these actually failing at" before touching the file. Improvement: when a build fails,
   pause and classify the failure (build-context, permissions, syntax, typo) before patching -
   this turns four scattered fixes into one deliberate pass.

2. A clean, immediate exit (code 0, no logs, empty inspect) was read as "the debug workflow
   failed" rather than "the workflow gave a complete and correct answer, but the test script
   doesn't reproduce the intended failure."
   Improvement: an instantly-clean exit is not a dead end to keep drilling into - it's a signal
   to check whether the reproduction setup actually matches the failure being studied. The fix
   is to correct the setup, not to search harder for information that genuinely isn't there.

3. Time-boxing was not respected - roughly an hour was spent stuck on the same wall before
   asking for a different approach, well past the standard 10-minute stuck-cap.
   Improvement: hold the 10-minute cap strictly, especially when the same three commands keep
   returning nothing new. Repeating an unproductive check for 60 minutes doesn't produce more
   signal than the first 10 did.

4. docker-init and tini were validated as working, but the actual mechanism (init system
   performing wait()/reaping on behalf of orphaned processes) was accepted from documentation
   without independently re-deriving why plain Python-as-PID-1 can't do this itself.
   Improvement: write the one-sentence mechanism from memory afterward - "an init process's job
   is to adopt orphaned children and reap them; ordinary application code was never written to
   do this" - so the concept transfers to the next PID-1-related bug rather than staying tied to
   this one script.

## Key Takeaways

- OCAT correctly reported "nothing wrong" when the reproduction script itself was flawed - trust
  a clean, complete answer from the workflow, and treat it as a prompt to re-examine the test
  setup, not the debugging method.
- Zombies are only observable while the parent process is still alive - a script that exits
  quickly can hide the exact failure it's meant to demonstrate.
- `--init` (or tini) fixes this by giving the container a real init process at PID 1 that reaps
  orphaned children - something ordinary application runtimes were never built to do.