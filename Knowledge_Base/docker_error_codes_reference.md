
## Docker Container Exit Codes Reference

When a Docker container exits, it returns an exit code that can provide insights into why it stopped. Here's a reference table for common exit codes and their meanings:

| Code | Meaning | First thing to check |
| :--- | :--- | :--- |
| **0** | Exited cleanly | CMD ran and finished — should it loop? |
| **1** | General error | `docker logs` — app threw an exception |
| **2** | Misuse of shell | Script syntax error |
| **126** | Permission denied | Can't execute the CMD binary |
| **127** | Command not found | Binary not installed in image, or typo in CMD |
| **137** | SIGKILL (OOM or manual kill) | `dmesg` or check if system ran out of memory |
| **139** | Segfault | C/C++ app, memory corruption |
| **143** | SIGTERM (graceful shutdown) | Normal for stopped containers |