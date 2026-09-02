# docker-cuprate

Debian-based docker setup for cuprate [Cuprate](https://github.com/Cuprate/cuprate) releases. 


## Requirements
* Docker
* Docker Compose

## Quick Start

1. Clone this repository and enter the directory.
2. Start the node (this will automatically fetch the latest release, build the Docker image, and run it):
   ```bash
   docker compose up -d --build
   ```

## Folder Structure & Data
When you run the node for the first time, it will generate a `./cuprate-data` directory on your host machine.
This contains all the blockchain state so the container is stateless.

## Ports
* **Wallet RPC (Port 18089):** Exposed on docker host by default. Point your wallet to `<your-host-ip>:18089`. 
* **P2P (Port 18080):** Exposed to sync with the Monero network. Forwarding this port from your router helps the network.

## Versioning
The latest release of Cuprate is used by default.  See the `docker-compose.yml` if you want to use a specific release tag.
