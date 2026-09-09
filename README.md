# cuprate-docker

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
3. If your current user ID is not 1000 (check with `id -u`), change the `cuprate-data`
   ownership to 1000 to match the UID running Cuprate in the container:
   ```bash
   sudo chown -R 1000:1000 ./cuprate-data
   ```
4. Start the node. This will fetch the latest release, build the Docker image,
   and run it:
   ```bash
   docker compose up --detach --build
   ```

## Configuration

The `Cuprated.toml` at the top of this repo is mounted into the
container at `/config/cuprate/Cuprated.toml`.

### Viewing all available settings

To see all the options that you could potentially put into `Cuprated.toml`, 
you can generate a full template using 
`cuprated --generate-config`. Here's how to do that both inside and outside
the container.

#### On a local Linux host with `curl`, `jq`, and `tar` installed:
`download-cuprate.sh` helper fetches the release binary into `./cuprate-release/`:
```bash
./download-cuprate.sh
./cuprate-release/cuprated --generate-config > Cuprated-template.toml
```

#### Inside the container
Build the image first with `docker compose build` if you haven't already:
```bash
docker compose run --rm --no-TTY cuprate-node --generate-config > Cuprated-template.toml
```

Copy any settings you want from the template into `Cuprated.toml`.

### Applying config changes (if the node is already running)

After editing `Cuprated.toml`, restart the node to pick up the changes:
```bash
docker compose restart
```

## Ports

### Restricted RPC port for Wallets (18089)

We expose this restricted RPC port on the Docker host, as wallets connect to it to
synchronize and send transactions. Point your wallet to `<your-docker-host-ip>:18089`.

There is no authentication on it at the current time, so take consideration before
exposing it on a public IP, as it could drive up the load on your host if lots of
wallets start connecting to it.

### P2P Port (18080)

Exposed for inbound connections from other nodes. If you are on
a private network, forwarding a port on your router to this port will help the
Monero network.

## Managing the Node

All of Cuprate's state is stored in the mounted `cuprate-data` folder, so the
Docker container is completely stateless and disposable. You can stop, delete,
and recreate the container at any time without losing your synced data.

### View live logs
```bash
docker compose logs -f
```

### Shut down the node
The container is stateless, so using `down` is arguably better than `stop`.
We don't need to save the container between runs.
```bash
docker compose down
```

### Update to a newer release
```bash
docker compose build --no-cache
docker compose up --detach
```

## Versioning

The latest release of Cuprate is used by default. See the `docker-compose.yml` if you want to
use a specific release tag.
