# Dockerfile — build Piston from source, run in /tmp so writes are allowed
FROM node:18-bullseye

# minimal tools
RUN apt-get update && apt-get install -y git ca-certificates --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# create an app dir and clone piston repo into it
WORKDIR /app

# clone latest piston source into /app
RUN git clone --depth 1 https://github.com/engineer-man/piston.git /app

# create writable isolate folder under /tmp (Render allows /tmp)
RUN mkdir -p /tmp/isolate && chown -R node:node /tmp/isolate /app

# switch to non-root user (node image has 'node' user)
USER node
WORKDIR /app

# install production dependencies for the project's node services
RUN npm ci --production || true

# copy and use a small robust entrypoint script (see below)
COPY --chown=node:node docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

ENV PISTON_ISOLATE_DIR=/tmp/isolate
EXPOSE 2000

ENTRYPOINT ["/app/docker-entrypoint.sh"]
