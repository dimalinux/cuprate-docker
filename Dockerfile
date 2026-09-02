# ==============================================================================
# Stage 1: Fetcher/Builder
# ==============================================================================
FROM debian:trixie-slim AS builder

# Install dependencies needed by download-cuprate.sh
RUN apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl jq tar

WORKDIR /cuprate-build

COPY download-cuprate.sh .
RUN chmod +x download-cuprate.sh

# Override this variable in docker-compose.yml if you want an older release
ARG CUPRATE_VERSION=latest

# Downloads and extracts release into /cuprate-build/cuprate_release/
RUN ./download-cuprate.sh "$CUPRATE_VERSION"

# ==============================================================================
# Stage 2: Final Image
# ==============================================================================
FROM debian:trixie-slim

# Install dependencies needed by cuprated executable
RUN apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates libstdc++6 && \
  rm -rf /var/lib/apt/lists/*

# Create the non-root user and the state directory
RUN useradd -m -d /home/cuprate -s /bin/bash cuprate && \
  mkdir -p /cuprate-data && \
  chown cuprate:cuprate /cuprate-data

# Copy/install the cuprated binary from the builder image
COPY --from=builder /cuprate-build/cuprate-release/cuprated /usr/local/bin/
RUN chmod +x /usr/local/bin/cuprated

# Switch to the non-root user
USER cuprate

# By default, cuprated scatters its state in several places.
# - ~/.local/share/cuprate/ contains the blockchain database.
# - ~/.config/cuprate/ contains the Cuprated.toml configuration file.
# - ~/.cache/cuprate/ contains the P2P network address book.
# We override these XDG environment variables to funnel everything into our single mounted volume.
ENV XDG_DATA_HOME=/cuprate-data/data
ENV XDG_CONFIG_HOME=/cuprate-data/config
ENV XDG_CACHE_HOME=/cuprate-data/cache

# Expose standard Monero network ports (Mainnet P2P, Restricted RPC)
EXPOSE 18080 18089

# Start the node
ENTRYPOINT ["/usr/local/bin/cuprated"]
