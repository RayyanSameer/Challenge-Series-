| Keyword in Situation | Pattern | First Command |
| :--- | :--- | :--- |
| **"won't start" / "exits immediately"** | Dead on arrival | `docker ps -a` → `docker logs <id>` → check exit code |
| **"unreachable" / "connection refused"** | Port/bind problem | `docker port <id>` → `docker exec <id> netstat -tlnp` |
| **"my change isn't showing"** | Cache/stale image | `docker compose up --build` or `docker build --no-cache` |
| **"permission denied"** | Filesystem permissions | `docker exec <id> ls -la /path` → check `WORKDIR` + file owner |
| **"environment variable not set"** | Env not passed | `docker exec <id> env` → add `-e` or check `environment:` in compose |
| **"slow / killed / OOM"** | Resource exhaustion | `docker stats` → `dmesg` |
| **"can't reach other container"** | Network isolation | `docker network ls` → `docker inspect <network>` |


### Debugging Docker Containers: A Quick Reference

Container won't start?
  └── docker ps -a              (is it dead or never ran?)
      └── docker logs <id>      (what did stdout/stderr say?)
          └── exit code 0?      (app finished normally — CMD wrong)
          └── exit code 1?      (app crashed — check logs for error)
          └── exit code 127?    (command not found — CMD typo or missing binary)
          └── exit code 137?    (OOM killed — check dmesg)
          └── logs empty?       → docker inspect <id>  (config problem)
              └── docker run --entrypoint /bin/sh image  (get inside)

Container starts but unreachable?
  └── docker inspect <id> | grep -A 10 "Ports"
      └── ports bound?  → app binding to 127.0.0.1 not 0.0.0.0
      └── ports empty?  → forgot -p flag at run time

Container acts weird?
  └── docker exec -it <id> /bin/sh   (get inside live container)
      └── check env vars: env
      └── check filesystem: ls /app
      └── check process: ps aux

## When Inspect and Logs Aren't Enough: Getting Inside the Container

# Get inside a running container
docker exec -it <id> /bin/sh

# Get inside a stopped container (can't exec into stopped)
docker run --entrypoint /bin/sh <image>   # fresh container, same image
docker run --entrypoint /bin/sh -v /var/lib/docker/containers/<id>:/mnt <image>  # mount dead container's FS

# Check actual network from inside
docker exec <id> netstat -tlnp     # what ports is the app actually listening on?
docker exec <id> env               # what env vars does the running process see?
docker exec <id> cat /etc/hosts    # what DNS entries exist?

# Read container filesystem from host without exec
docker cp <id>:/app/logs/error.log ./  # extract files from container
