# Docker Scenario 6 - Sensitive Information Baked Into Dockerfile

A secret set via ENV, then "cleared" in a later instruction - proving that Docker layers are
immutable and the secret remains fully recoverable from image history regardless of later
instructions.

## Setup

    FROM python:3.12-slim
    WORKDIR /app
    ENV API_KEY=supersecret123
    RUN echo "using key: $API_KEY"
    ENV API_KEY=
    COPY . .
    CMD ["python", "app.py"]

    docker build -t secretleak .

## Observe

Build succeeded cleanly, but BuildKit itself flagged the problem unprompted:

    2 warnings found (use docker --debug to expand):
    - SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions for sensitive data (ENV "API_KEY") (line 3)
    - SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions for sensitive data (ENV "API_KEY") (line 5)

## Correlate

    docker history --no-trunc secretleak

Confirmed directly: the layer `ENV API_KEY=supersecret123` is present in the image history in
plain text, despite the later `ENV API_KEY=` instruction intended to clear it.

## Analyse

Why ENV fails for secrets:

1. **Public in metadata** - anyone running `docker inspect` or `docker history` on the image
   can read the value in plain text.
2. **Persists at runtime** - the variable is embedded into the running container's environment,
   exposed to any process, sub-process, or log inside the container.
3. **Cannot be erased** - setting `ENV API_KEY=""` in a later layer does not remove the value
   from the earlier layer. Layers are immutable and additive; nothing is ever deleted, only
   stacked on top of.

### Decision tree - when do you actually need the secret?

                     Do you need the secret during...
                                     |
             +-----------------------+-----------------------+
             |                                                |
         BUILD TIME                                      RUN TIME
    (e.g. pulling a private                         (e.g. connecting to a
     git repo or npm package)                        database or API in production)
             |                                                |
             v                                                v
    Use BuildKit Secrets                          Use environment variables
    RUN --mount=type=secret                        at container launch
                                                    docker run -e SECRET=...

## Test / Fix

**Scenario A - runtime secret (e.g. database password, API key used by the running app):**
Do not put it in the Dockerfile at all. Supply it at launch:

    docker run -e API_KEY=supersecret123 secretleak-fixed

**Scenario B - build-time secret (e.g. a private git token needed only to install a
dependency during the build):**

    FROM python:3.12-slim
    WORKDIR /app
    RUN --mount=type=secret,id=my_token \
        TOKEN=$(cat /run/secrets/my_token) && \
        pip install "git+https://${TOKEN}@github.com/myorg/private-repo.git"
    COPY . .
    CMD ["python", "app.py"]

The secret is mounted only for the duration of that specific RUN instruction and is never
written into any image layer - `docker history` on the resulting image shows no trace of it.

## Root Cause

`ENV`/`ARG` values are baked permanently into image layers at the point they're set. A later
instruction that appears to clear or overwrite a value only adds a new layer on top - it does
not retroactively edit or remove the earlier one.

## Critical Follow-Up (not just "rebuild correctly")

Fixing future builds with BuildKit secret mounts does **not** un-leak the key that's already
in `secretleak`'s history. Two separate actions are required:

1. **Treat the original image as permanently compromised** - `secretleak:latest` must never
   be pushed to a registry or distributed, and should be deleted locally.
2. **Rotate the leaked key** - `supersecret123` (or any real secret in this position) must be
   considered burned and replaced at the source (e.g. the actual API provider), regardless of
   whether the image itself is deleted.

Rebuilding with the correct pattern only prevents the *next* leak - it does not retroactively
fix the one that already happened.

## Pattern

Supply-chain / secrets-hygiene failure. This is the same failure class flagged by BuildKit's
own built-in linter (`SecretsUsedInArgOrEnv`) - worth keeping that warning enabled and treating
it as a hard stop, not a note to dismiss.

## Key Takeaways

- Docker image layers are immutable and additive - nothing set in an earlier layer can be
  removed by a later one, only hidden from a shallow read of the final state.
- `docker history --no-trunc` is the actual verification step - don't rely on knowing the
  theory, confirm the secret is visible with your own eyes before considering the finding proven.
- Build-time secrets and run-time secrets need different mechanisms: `--mount=type=secret` for
  the former, `-e`/`--env-file` at launch for the latter. Neither belongs in a Dockerfile
  ENV/ARG instruction.
- Fixing the build pattern going forward and remediating an already-leaked secret are two
  separate, both-required actions - one does not substitute for the other.