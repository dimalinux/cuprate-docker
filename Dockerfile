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

# Create the non-root user, the state directory, and the config directory.
# The config dir lives outside the mounted volume and is pre-created here so the
# read-only Cuprated.toml bind mount lands in a cuprate-owned directory instead
# of one the Docker daemon would otherwise create as root.
RUN useradd -m -d /home/cuprate -s /bin/bash cuprate && \
  mkdir -p /cuprate-data /config/cuprate && \
  chown -R cuprate:cuprate /cuprate-data /config

# Copy/install the cuprated binary from the builder image
COPY --from=builder /cuprate-build/cuprate-release/cuprated /usr/local/bin/
RUN chmod +x /usr/local/bin/cuprated

# Switch to the non-root user
USER cuprate

# cuprated stores its files under XDG base dirs. Remap them so all persistent
# state is in the mounted `/cuprate-data` folder, and our repo-supplied config
# gets mounted in (read-only) at /config/cuprate/Cuprated.toml:
#   ~/.local/share/cuprate/ (blockchain data) -> /cuprate-data/data/cuprate/
#   ~/.config/cuprate/ (Cuprated.toml) -> /config/cuprate/
#   ~/.cache/cuprate/ (P2P address book) -> /cuprate-data/cache/cuprate/
ENV XDG_DATA_HOME=/cuprate-data/data
ENV XDG_CONFIG_HOME=/config
ENV XDG_CACHE_HOME=/cuprate-data/cache

# Expose standard Monero network ports (Mainnet P2P, Restricted RPC)
EXPOSE 18080 18089

# Start the node
ENTRYPOINT ["/usr/local/bin/cuprated"]
