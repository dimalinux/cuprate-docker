# docker-cuprate

Debian-based Docker setup for [Cuprate](https://github.com/Cuprate/cuprate) releases.

## Requirements

- Docker
- Docker Compose v2

## Quick Start

1. Clone this repository and enter the directory.
2. Create the persistent data directory. All node state will be stored in this folder:
   ```bash
   mkdir -p ./cuprate-data
   ```
3. If your current user ID is not 1000, change the `cuprate-data` ownership to 1000
   to match the UID running Cuprate in the container:
   ```bash
   sudo chown -R 1000:1000 ./cuprate-data
   ```
   *(Note: You can check your current user ID by running `id -u`.)*
4. Start the node (this will automatically fetch the latest release, build the Docker image,
   and run it):
   ```bash
   docker compose up --detach --build
   ```

## Managing the Node

All of Cuprate's state is stored in the mounted `cuprate-data` folder, so the
Docker container is completely stateless and disposable. You can stop, delete,
and recreate the container at any time without losing your synced data.

**View live logs:**
```bash
docker compose logs -f
```

**Stop the node:**
```bash
docker compose stop
```

**Stop and safely delete the container:**
*(This is the recommended way to shut down. Your data remains perfectly safe in `./cuprate-data`.)*
```bash
docker compose down
```

**Update to a newer release:**
```bash
docker compose build --no-cache
docker compose up --detach
```

## Ports

- **Node RPC for Wallets (Port 18089):** Exposed on the Docker host by default. Point your Monero wallet to
  `<your-host-ip>:18089`. This is the "restricted" RPC port without dangerous administrative commands, but
  take consideration before exposing it on a public IP, as there is no authentication on it at the current
  time and exposing it could increase the load on your node.
- **P2P (Port 18080):** Exposed for inbound connections from other nodes. If you are on
  a private network, forwarding a port on your router to this port will help the
  Monero network.

## Versioning

The latest release of Cuprate is used by default. See the `docker-compose.yml` if you want to
use a specific release tag.
