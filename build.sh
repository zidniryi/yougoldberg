#!/bin/bash

# Build script for yougoldberg - Cross-platform C++ file navigator
# Usage: ./build.sh [windows|native|all|pkg|clean|help]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Source files
SOURCES="main.cpp"

# Common compiler flags
COMMON_FLAGS="-std=c++17 -O2 -Wall -Wextra"

# Package information
PKG_IDENTIFIER="com.yougoldberg.osint"
PKG_VERSION="1.0.0"
PKG_NAME="yougoldberg-installer"

echo -e "${BLUE}🚀 yougoldberg Build Script${NC}"
echo -e "${BLUE}=====================${NC}"

build_native() {
    echo -e "\n${YELLOW}Building for native platform (Unix/Linux/macOS)...${NC}"
    
    # Check if libcurl is available
    if ! pkg-config --exists libcurl; then
        echo -e "${RED}❌ Error: libcurl development package not found${NC}"
        echo -e "${RED}   Please install: libcurl4-openssl-dev (Ubuntu/Debian) or curl (macOS)${NC}"
        echo -e "${RED}   macOS: brew install curl${NC}"
        echo -e "${RED}   Ubuntu: sudo apt install libcurl4-openssl-dev${NC}"
        return 1
    fi
    
    g++ $COMMON_FLAGS -o yougoldberg-native $SOURCES $(pkg-config --cflags --libs libcurl)
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Native build successful: yougoldberg-native${NC}"
    else
        echo -e "${RED}❌ Native build failed${NC}"
        return 1
    fi
}

build_windows() {
    echo -e "\n${YELLOW}Building for Windows (cross-compilation)...${NC}"
    
    # Check if MinGW cross-compiler is available
    if ! command -v x86_64-w64-mingw32-g++ &> /dev/null; then
        echo -e "${RED}❌ Error: MinGW-w64 cross-compiler not found${NC}"
        echo -e "${RED}   Please install: mingw-w64 package${NC}"
        echo -e "${RED}   macOS: brew install mingw-w64${NC}"
        echo -e "${RED}   Ubuntu: sudo apt install mingw-w64${NC}"
        return 1
    fi
    
    # Check for libcurl for MinGW
    echo -e "${YELLOW}🔍 Checking for libcurl for MinGW...${NC}"
    
    # Try different libcurl locations
    CURL_PATHS=(
        "/usr/x86_64-w64-mingw32"
        "/usr/local/x86_64-w64-mingw32" 
        "/opt/mingw64"
        "$(brew --prefix 2>/dev/null)/x86_64-w64-mingw32"
        "./curl-mingw"
    )
    
    CURL_FOUND=false
    for path in "${CURL_PATHS[@]}"; do
        if [ -f "$path/include/curl/curl.h" ]; then
            echo -e "${GREEN}✅ Found libcurl at: $path${NC}"
            MINGW_PREFIX="$path"
            CURL_FOUND=true
            break
        fi
    done
    
    # Skip libcurl creation for now - build without it
    echo -e "${YELLOW}⚠️  Building Windows executable without libcurl${NC}"
    echo -e "${YELLOW}   This will create a non-functional executable for testing purposes${NC}"
    CURL_FOUND=false
    
    # Build Windows executable (with or without libcurl)
    echo -e "${YELLOW}🔨 Building Windows executable...${NC}"
    
    if [ "$CURL_FOUND" = true ]; then
        # Build with libcurl
        x86_64-w64-mingw32-g++ \
            -std=c++17 -O2 -static \
            -I"$MINGW_PREFIX/include" \
            -L"$MINGW_PREFIX/lib" \
            -o yougoldberg-windows.exe main.cpp \
            "$MINGW_PREFIX/lib/libcurl.a" -lws2_32 -lcrypt32 -lwinmm \
            -static-libgcc -static-libstdc++
    else
        # Build without libcurl (will show error but creates executable)
        echo -e "${YELLOW}⚠️  Building without libcurl - executable will not be functional${NC}"
        x86_64-w64-mingw32-g++ \
            -std=c++17 -O2 -static \
            -o yougoldberg-windows.exe main.cpp \
            -static-libgcc -static-libstdc++ \
            -DNO_CURL
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Windows build successful: yougoldberg-windows.exe${NC}"
        if [ "$CURL_FOUND" = false ]; then
            echo -e "${YELLOW}⚠️  Note: This executable was built without libcurl and will not function properly${NC}"
            echo -e "${YELLOW}💡 To build a functional version, install libcurl for MinGW${NC}"
        fi
        return 0
    fi
    
    echo -e "${RED}❌ Windows build failed${NC}"
    return 1
}

create_macos_package() {
    echo -e "\n${YELLOW}Creating macOS package installer...${NC}"
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}❌ Error: macOS package creation is only supported on macOS${NC}"
        return 1
    fi
    
    # Check if native binary exists
    if [ ! -f "yougoldberg-native" ]; then
        echo -e "${YELLOW}📦 Native binary not found, building first...${NC}"
        build_native
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Failed to build native binary for package${NC}"
            return 1
        fi
    fi
    
    # Create package root directory structure
    PKG_ROOT="pkg-root"
    PKG_INSTALL_PATH="$PKG_ROOT/usr/local/bin"
    PKG_DOC_PATH="$PKG_ROOT/usr/local/share/doc/yougoldberg"
    PKG_MAN_PATH="$PKG_ROOT/usr/local/share/man/man1"
    
    echo -e "${BLUE}📁 Creating package directory structure...${NC}"
    rm -rf "$PKG_ROOT"
    mkdir -p "$PKG_INSTALL_PATH"
    mkdir -p "$PKG_DOC_PATH"
    mkdir -p "$PKG_MAN_PATH"
    
    # Copy binary
    echo -e "${BLUE}📋 Copying binary and documentation...${NC}"
    cp yougoldberg-native "$PKG_INSTALL_PATH/yougoldberg"
    chmod +x "$PKG_INSTALL_PATH/yougoldberg"
    
    # Copy documentation
    cp README.md "$PKG_DOC_PATH/" 2>/dev/null || echo "README.md not found, skipping..."
    cp LICENSE "$PKG_DOC_PATH/" 2>/dev/null || echo "LICENSE not found, skipping..."
    cp CONTRIBUTING.md "$PKG_DOC_PATH/" 2>/dev/null || echo "CONTRIBUTING.md not found, skipping..."
    
    # Create man page
    create_man_page "$PKG_MAN_PATH/yougoldberg.1"
    
    # Create package scripts directory
    PKG_SCRIPTS="pkg-scripts"
    mkdir -p "$PKG_SCRIPTS"
    
    # Create postinstall script
    cat > "$PKG_SCRIPTS/postinstall" << 'EOF'
#!/bin/bash
# Postinstall script for YouGoldberg

# Make sure the binary is executable
chmod +x /usr/local/bin/yougoldberg

# Update man database if available
if command -v mandb >/dev/null 2>&1; then
    mandb -q /usr/local/share/man 2>/dev/null || true
fi

echo "YouGoldberg has been installed successfully!"
echo "You can now run 'yougoldberg <username>' from anywhere."
echo "For help, run 'yougoldberg --help' or 'man yougoldberg'."

exit 0
EOF
    
    # Create preinstall script
    cat > "$PKG_SCRIPTS/preinstall" << 'EOF'
#!/bin/bash
# Preinstall script for YouGoldberg

# Check if old installation exists and remove it
if [ -f "/usr/local/bin/yougoldberg" ]; then
    echo "Removing previous YouGoldberg installation..."
    rm -f /usr/local/bin/yougoldberg
fi

exit 0
EOF
    
    chmod +x "$PKG_SCRIPTS/postinstall"
    chmod +x "$PKG_SCRIPTS/preinstall"
    
    # Build the package
    echo -e "${BLUE}📦 Building package...${NC}"
    pkgbuild --root "$PKG_ROOT" \
             --identifier "$PKG_IDENTIFIER" \
             --version "$PKG_VERSION" \
             --install-location / \
             --scripts "$PKG_SCRIPTS" \
             "$PKG_NAME.pkg"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ macOS package created successfully: $PKG_NAME.pkg${NC}"
        
        # Clean up temporary directories
        rm -rf "$PKG_ROOT" "$PKG_SCRIPTS"
        
        # Show package info
        echo -e "${BLUE}📋 Package Information:${NC}"
        echo -e "   Package: $PKG_NAME.pkg"
        echo -e "   Identifier: $PKG_IDENTIFIER"
        echo -e "   Version: $PKG_VERSION"
        echo -e "   Size: $(du -h $PKG_NAME.pkg | cut -f1)"
        
        echo -e "\n${YELLOW}💡 Installation Instructions:${NC}"
        echo -e "   1. Double-click $PKG_NAME.pkg to install"
        echo -e "   2. Or use: sudo installer -pkg $PKG_NAME.pkg -target /"
        echo -e "   3. After installation, run: yougoldberg <username>"
    else
        echo -e "${RED}❌ macOS package creation failed${NC}"
        rm -rf "$PKG_ROOT" "$PKG_SCRIPTS"
        return 1
    fi
}

create_man_page() {
    local man_file="$1"
    cat > "$man_file" << 'EOF'
.TH YOGOLDBERG 1 "2024" "YouGoldberg 1.0.0" "User Commands"
.SH NAME
yougoldberg \- OSINT Username Discovery Tool - Search usernames across 101+ platforms
.SH SYNOPSIS
.B yougoldberg
[\fIOPTION\fR] \fIUSERNAME\fR
.SH DESCRIPTION
YouGoldberg is a fast and efficient C++ CLI tool for Open Source Intelligence (OSINT) that searches for usernames across 101+ popular platforms and services. It uses HTTP HEAD requests for efficient checking and provides a beautiful colored interface.
.SH OPTIONS
.TP
.B \-v, \-\-verbose
Enable verbose output showing all checked URLs
.TP
.B \-t, \-\-timeout \fISECONDS\fR
Set timeout in seconds (default: 10)
.TP
.B \-h, \-\-help
Display help information
.TP
.B \-\-version
Display version information
.SH EXAMPLES
.TP
.B yougoldberg johndoe
Search for username "johndoe" across all platforms
.TP
.B yougoldberg \-v \-t 15 techuser
Verbose search with 15-second timeout
.TP
.B yougoldberg \-\-help
Show help information
.SH PLATFORMS
The tool checks 101+ platforms including:
.TP
.B Development & Code
GitHub, GitLab, StackOverflow, Dev.to, Codepen, Replit
.TP
.B Social Media
Twitter, Facebook, Instagram, LinkedIn, TikTok, Pinterest
.TP
.B Content Creation
YouTube, Twitch, Medium, Blogger, WordPress, Tumblr
.TP
.B Design & Art
Behance, Dribbble, DeviantArt, ArtStation, 500px
.TP
.B Gaming
Steam, Twitch, Roblox, Chess.com, NameMC
.TP
.B Security & Research
HackerOne, Bugcrowd, TryHackMe, HackTheBox
.SH PERFORMANCE
.TP
.B Average Speed
~1.5 requests per second (with rate limiting)
.TP
.B Memory Usage
Minimal (~5MB)
.TP
.B Network Efficient
Uses HEAD requests only
.SH ETHICAL USAGE
This tool is designed for educational and legitimate security research purposes only. Do NOT use for stalking, harassment, or malicious activities.
.SH AUTHOR
YouGoldberg development team
.SH BUGS
Report bugs at: https://github.com/your-repo/yougoldberg/issues
EOF
}

show_help() {
    echo -e "\nUsage: $0 [windows|native|all|pkg|clean|help]"
    echo -e ""
    echo -e "Commands:"
    echo -e "  native   - Build for current platform (requires ncurses)"
    echo -e "  windows  - Cross-compile for Windows (requires MinGW-w64)"
    echo -e "  all      - Build for both platforms"
    echo -e "  pkg      - Create macOS package installer (macOS only)"
    echo -e "  clean    - Remove build artifacts"
    echo -e "  help     - Show this help message"
    echo -e ""
    echo -e "Examples:"
    echo -e "  $0 all       # Build for both platforms"
    echo -e "  $0 windows   # Build only Windows version"
    echo -e "  $0 pkg       # Create macOS .pkg installer"
}

clean_builds() {
    echo -e "\n${YELLOW}Cleaning build artifacts...${NC}"
    rm -f yougoldberg-native yougoldberg-windows.exe yougoldberg-installer.pkg
    rm -rf pkg-root pkg-scripts
    echo -e "${GREEN}✅ Clean complete${NC}"
}

# Main execution
case "${1:-all}" in
    "native")
        build_native
        ;;
    "windows")
        build_windows
        ;;
    "all")
        build_native
        build_windows
        ;;
    "pkg")
        create_macos_package
        ;;
    "clean")
        clean_builds
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac

if [ "$1" != "clean" ] && [ "$1" != "help" ] && [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
    echo -e "\n${BLUE}📋 Build Summary${NC}"
    echo -e "${BLUE}=================${NC}"
    if [ -f yougoldberg-native ]; then
        echo -e "${GREEN}✅ Native executable: yougoldberg-native ($(du -h yougoldberg-native | cut -f1))${NC}"
    fi
    if [ -f yougoldberg-windows.exe ]; then
        echo -e "${GREEN}✅ Windows executable: yougoldberg-windows.exe ($(du -h yougoldberg-windows.exe | cut -f1))${NC}"
    fi
    if [ -f yougoldberg-installer.pkg ]; then
        echo -e "${GREEN}✅ macOS package: yougoldberg-installer.pkg ($(du -h yougoldberg-installer.pkg | cut -f1))${NC}"
    fi
    
    echo -e "\n${YELLOW}💡 Usage Tips:${NC}"
    echo -e "   ./yougoldberg-native <username>              # Run on Unix/Linux/macOS"
    echo -e "   wine yougoldberg-windows.exe <username>    # Test Windows version on Unix"
    if [ -f yougoldberg-installer.pkg ]; then
        echo -e "   sudo installer -pkg yougoldberg-installer.pkg -target /  # Install macOS package"
    fi
fi 