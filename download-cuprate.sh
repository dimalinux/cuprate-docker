#!/usr/bin/env bash
# Exit immediately if command or pipe fails, or an unset variable is used
set -euo pipefail

VERSION="${1:-latest}"

if [ "$VERSION" = "latest" ]; then
  API_URL="https://api.github.com/repos/Cuprate/cuprate/releases/latest"
else
  API_URL="https://api.github.com/repos/Cuprate/cuprate/releases/tags/${VERSION}"
fi

echo "Fetching release data from $API_URL"
# Query the GitHub API and filter for the Linux x86_64 asset
DOWNLOAD_URL=$(curl -sL "$API_URL" | jq -r '.assets[] | select(.name | test("linux.*x86_64|x86_64.*linux|amd64"; "i")) | .browser_download_url' | head -n 1)

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
  echo "Error: Could not find a Linux x86_64 release asset."
  exit 1
fi

echo "Downloading $DOWNLOAD_URL ..."
curl -sL "$DOWNLOAD_URL" -o cuprate-release.tar.gz

echo "Extracting archive..."
# Clean up any previous extractions and create a fresh directory
rm -rf cuprate-release
mkdir cuprate-release

# Extract the full contents into the directory
tar -xzf cuprate-release.tar.gz -C cuprate-release

echo "Cleaning up..."
rm cuprate-release.tar.gz

# Robustly find the binary in case it is nested, get the version JSON, and parse the semantic_version
CUPRATE_BIN=$(find cuprate-release -type f -name "cuprated" | head -n 1)
SEMANTIC_VERSION=$("$CUPRATE_BIN" --version | jq -r '.semantic_version')

echo "Cuprate version $SEMANTIC_VERSION successfully downloaded to $CUPRATE_BIN"
