# Native ARM64 slim Linux base for Apple M4 core speed performance
FROM --platform=linux/arm64 debian:bookworm-slim

# Install the true GNU AWK package
RUN apt-get update && apt-get install -y --no-install-recommends \
    gawk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /pipeline
COPY . .

# Run your gawk analytics engine directly over incoming text streams
ENTRYPOINT ["gawk", "-f", "gawk_monitor.awk"]
