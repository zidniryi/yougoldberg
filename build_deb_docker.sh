#!/bin/bash

set -e

echo "🐳 Building yougoldberg .deb package using Docker..."

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Error: Docker is not installed or not running"
    echo "   Please install Docker Desktop and start it"
    exit 1
fi

# Build the binary first (if not already built)
if [ ! -f "build/yougoldberg" ]; then
    echo "🔧 Building yougoldberg binary first..."
    ./build_deb.sh
fi

echo "📦 Creating .deb package in Docker container..."

# Run Docker container to build the .deb package
docker run --rm -v "$(pwd):/work" debian:bullseye bash -c '
    cd /work
    apt update
    apt install -y dpkg-dev
    dpkg-deb --build yougoldberg_deb
    chown $(id -u):$(id -g) yougoldberg_deb.deb
'

if [ $? -eq 0 ]; then
    echo "✅ Done! Output: yougoldberg_deb.deb"
    echo "📊 Package size: $(du -h yougoldberg_deb.deb | cut -f1)"
    echo "💡 Install on Debian/Ubuntu: sudo dpkg -i yougoldberg_deb.deb"
else
    echo "❌ Failed to build .deb package"
    exit 1
fi 