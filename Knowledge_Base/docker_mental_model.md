## Docker Mental Model

Dockerfile → [docker build] → Image → [docker run] → Container
                                          ↓
                                       Registry (push/pull)

Host filesystem ←→ Container filesystem (via -v volume mount)

Container process ←→ Host process (via docker exec or logs)
Container network ←→ Host network (via -p port mapping)
