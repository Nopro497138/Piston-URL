FROM ghcr.io/engineer-man/piston:latest

# Set working dir to /tmp where writing is allowed
WORKDIR /tmp

# Create isolate dir inside /tmp
RUN mkdir -p /tmp/isolate

# Start piston with custom path
CMD ["sh", "-c", "PISTON_PATH=/tmp/isolate node /piston/index.js"]

