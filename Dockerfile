# Dockerfile — Render-friendly build that installs dependencies for a monorepo/workspace
FROM node:18-bullseye

# install minimal build deps
RUN apt-get update && apt-get install -y git ca-certificates python3 build-essential --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# set workdir
WORKDIR /app

# clone piston source into image
RUN git clone --depth 1 https://github.com/engineer-man/piston.git /app

# ensure /tmp isolate dir exists (writable on Render)
RUN mkdir -p /tmp/isolate

# --- Install dependencies as root (important for workspaces / local linking) ---
# Use npm install (not "ci") so workspace linking happens reliably; support legacy peers.
RUN npm install --legacy-peer-deps

# try build step if present (some repos need it)
RUN if [ -f package.json ]; then \
      if grep -q "\"build\"" package.json 2>/dev/null; then \
        npm run build || true; \
      fi \
    fi

# fix permissions: let non-root user own app and tmp
RUN chown -R node:node /app /tmp/isolate

# switch to non-root user
USER node
WORKDIR /app

# copy entrypoint (we'll provide this file)
COPY --chown=node:node docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# make sure runtime sees local modules (helpful for monorepos)
ENV NODE_PATH=/app/node_modules:/app/packages/*/node_modules
ENV PISTON_ISOLATE_DIR=/tmp/isolate
EXPOSE 2000

ENTRYPOINT ["/app/docker-entrypoint.sh"]
