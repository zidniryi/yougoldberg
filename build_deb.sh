#!/bin/bash

set -e

echo "🔧 Building yougoldberg binary..."

mkdir -p build
g++ -std=c++17 -O2 -Wall -Wextra -o build/yougoldberg \
    main.cpp \
    $(pkg-config --cflags --libs libcurl)

echo "📦 Setting up Debian package structure..."

rm -rf yougoldberg_deb
mkdir -p yougoldberg_deb/usr/local/bin
mkdir -p yougoldberg_deb/usr/local/share/doc/yougoldberg
mkdir -p yougoldberg_deb/usr/local/share/man/man1
mkdir -p yougoldberg_deb/DEBIAN

cp build/yougoldberg yougoldberg_deb/usr/local/bin/
chmod +x yougoldberg_deb/usr/local/bin/yougoldberg

# Copy documentation
cp README.md yougoldberg_deb/usr/local/share/doc/yougoldberg/ 2>/dev/null || echo "README.md not found, skipping..."

# Create man page
cat > yougoldberg_deb/usr/local/share/man/man1/yougoldberg.1 << 'EOF'
.TH YOGOLDBERG 1 "2024" "YouGoldberg 1.0.0" "User Commands"
.SH NAME
yougoldberg \- OSINT Username Discovery Tool - Search usernames across 101+ platforms
.SH SYNOPSIS
.B yougoldberg
[\fIOPTION\fR] \fIUSERNAME\fR
.SH DESCRIPTION
YouGoldberg is a fast and efficient C++ CLI tool for Open Source Intelligence (OSINT) that searches for usernames across 101+ popular platforms and services.
.SH OPTIONS
.TP
.B \-v, \-\-verbose
Enable verbose output
.TP
.B \-t, \-\-timeout \fISECONDS\fR
Set timeout in seconds (default: 10)
.TP
.B \-h, \-\-help
Display help information
.SH EXAMPLES
.TP
.B yougoldberg johndoe
Search for username "johndoe"
.TP
.B yougoldberg \-v \-t 15 techuser
Verbose search with 15-second timeout
.SH AUTHOR
YouGoldberg development team
EOF

cat <<EOF > yougoldberg_deb/DEBIAN/control
Package: yougoldberg
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Zidni Ridwan <your@email.com>
Depends: libcurl4
Description: yougoldberg - A OSINT Username Discovery Tool.
 YouGoldberg is a fast and efficient C++ CLI tool for Open Source Intelligence (OSINT) 
 that searches for usernames across 101+ popular platforms and services.
EOF

echo "📦 Building .deb package..."

# Check if dpkg-deb is available
if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb --build yougoldberg_deb
    echo "✅ Done! Output: yougoldberg_deb.deb"
else
    echo "⚠️  dpkg-deb not found on this system (macOS/other)"
    echo "📦 Debian package structure created in: yougoldberg_deb/"
    echo "💡 To build .deb package, you need:"
    echo "   - Ubuntu/Debian system, or"
    echo "   - Docker with Debian image, or"
    echo "   - Install dpkg-dev package"
    echo ""
    echo "🔧 Alternative: Use Docker to build .deb package:"
    echo "   docker run --rm -v \$(pwd):/work debian:bullseye bash -c 'cd /work && apt update && apt install -y dpkg-dev && ./build_deb.sh'"
fi
