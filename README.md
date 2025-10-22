# YouGoldberg - OSINT Username Discovery Tool 🔍

A fast and efficient C++ CLI tool for Open Source Intelligence (OSINT) that searches for usernames across 101+ popular platforms and services.

## Features

- 🚀 **Fast Multi-Platform Search**: Check username availability across 101+ platforms
- 🎯 **HTTP Status Verification**: Uses HEAD requests for efficient checking
- 🎨 **Beautiful CLI Interface**: Colored output with progress indicators
- 📄 **Export Results**: Save findings to JSON or TXT files
- ⚙️ **Configurable**: Adjustable timeout and verbose mode
- 🔒 **Responsible**: Built with rate limiting to respect server resources

## Download

Ready-to-use executables are available for all major platforms:

### Latest Release: [v1.1](https://github.com/zidniryi/yougoldberg/releases/tag/v1.1)

| Platform | Download | Size | Notes |
|----------|----------|------|-------|
| **Windows** | [yougoldberg-windows.exe](https://github.com/zidniryi/yougoldberg/releases/download/v1.1/yougoldberg-windows.exe) | 12MB | ⚠️ Requires libcurl for full functionality |
| **Linux** | [yougoldberg-native](https://github.com/zidniryi/yougoldberg/releases/download/v1.1/yougoldberg-native) | 68KB | Static binary for x86_64 |
| **macOS** | [yougoldberg-installer.pkg](https://github.com/zidniryi/yougoldberg/releases/download/v1.1/yougoldberg-installer.pkg) | 24KB | Package installer |
| **Universal** | [Source Code (ZIP)](https://github.com/zidniryi/yougoldberg/archive/refs/tags/v1.1.zip) | - | Build from source |

### Quick Start

```bash
# Download and run (Linux/macOS)
wget https://github.com/zidniryi/yougoldberg/releases/download/v1.1/yougoldberg-native
chmod +x yougoldberg-native
./yougoldberg-native johndoe

# Export results to JSON
./yougoldberg-native -j johndoe

# Export results to TXT file
./yougoldberg-native -o results.txt johndoe

# Windows (download and run)
# Download yougoldberg-windows.exe and run in Command Prompt
yougoldberg-windows.exe johndoe

# macOS (install via package)
# Download yougoldberg-installer.pkg and double-click to install
```

## Prerequisites

Before building, ensure you have:

- **CMake** (version 3.10 or higher)
- **C++ Compiler** with C++17 support (GCC, Clang, or MSVC)
- **libcurl** development libraries

### Installing Dependencies

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install cmake build-essential libcurl4-openssl-dev
```

#### macOS:
```bash
brew install cmake curl
```

#### CentOS/RHEL:
```bash
sudo yum install cmake gcc-c++ libcurl-devel
# or for newer versions:
sudo dnf install cmake gcc-c++ libcurl-devel
```

## Building

### Standard Build (CMake)

1. **Clone or download the project**
2. **Navigate to project directory**
3. **Create build directory and compile:**

```bash
mkdir build
cd build
cmake ..
make
```

### Cross-Platform Build Scripts

For convenience, use the provided build scripts:

```bash
# Build all platforms (native + Windows)
./build.sh

# Build specific platforms
./build.sh native   # Linux/macOS only
./build.sh windows  # Windows cross-compilation only

# Package builds
./build.sh pkg      # macOS package installer
./build.sh deb      # Debian package (Linux only)
```

### Windows Build Status

**Current Status**: ✅ **Working** - Creates Windows executable successfully

```bash
# Build Windows executable
./build.sh windows
```

**Output**: `yougoldberg-windows.exe` (12MB static executable)

**Important Notes**:
- ⚠️ **Current Windows build is compiled without libcurl** for compatibility
- ⚠️ **The Windows executable will not function properly** without libcurl
- ✅ **The executable compiles and runs** but cannot make HTTP requests

### Making Windows Build Fully Functional

To create a fully functional Windows executable, you have several options:

#### Option 1: Install libcurl for MinGW (Recommended)
```bash
# macOS
brew install mingw-w64 curl

# Ubuntu/Debian
sudo apt install mingw-w64 libcurl4-openssl-dev

# Then rebuild
./build.sh windows
```

#### Option 2: Build on Windows directly
```bash
# Install Visual Studio with C++ support
# Install vcpkg: git clone https://github.com/Microsoft/vcpkg.git
# Install curl: vcpkg install curl[core]:x64-windows-static
# Build with CMake
```

#### Option 3: Use Docker (if available)
```bash
# Requires Docker Desktop
docker run --rm -v "$(pwd):/app" -w /app ubuntu:22.04 bash -c "
  apt update && apt install -y mingw-w64 g++-mingw-w64 wget
  # Build libcurl and yougoldberg
"
```

## Usage

### Basic Usage
```bash
./yougoldberg <username>
```

### Options
- `-v, --verbose` - Enable verbose output showing all checked URLs
- `-t, --timeout` - Set timeout in seconds (default: 10)
- `-j, --json` - Export results to JSON file
- `-o, --output` - Export results to TXT file
- `-h, --help` - Show help message

### Examples

**Basic search:**
```bash
./yougoldberg johndoe
```

**Verbose mode with custom timeout:**
```bash
./yougoldberg -v -t 15 techuser
```

**Export to JSON:**
```bash
./yougoldberg -j johndoe
# Creates: johndoe_results.json
```

**Export to TXT file:**
```bash
./yougoldberg -o results.txt johndoe
```

**Combine options:**
```bash
./yougoldberg -v -j -t 20 johndoe
```

**Get help:**
```bash
./yougoldberg --help
```

## Sample Output

```

    ██    ██  ██████  ██    ██ 
     ██  ██  ██    ██ ██    ██ 
      ████   ██    ██ ██    ██ 
       ██    ██    ██ ██    ██
       ██     ██████   ██████  	
                                                            
 🔍 yougoldberg OSINT Username Discovery Tool 🔍            
              Version 1.0                             


🔍 Searching for username: techuser
📊 Checking 101 platforms...

Progress: [101/101] Checking Chess.com...
  ✓ FOUND: GitHub
  ✓ FOUND: Twitter
  ✓ FOUND: Reddit

🎯 Found 3 profile(s):

┌─────────────────────────┬────────────────────────────────────────────────────────┐
│ Platform                │ URL                                                    │
├─────────────────────────┼────────────────────────────────────────────────────────┤
│ GitHub                  │ https://github.com/techuser                           │
│ Twitter                 │ https://twitter.com/techuser                          │
│ Reddit                  │ https://www.reddit.com/user/techuser                  │
└─────────────────────────┴────────────────────────────────────────────────────────┘

⏱️  Search completed in 45 seconds
⚠️  Remember: This tool is for educational and legitimate research purposes only!
```

## Supported Platforms

The tool checks 101+ platforms including:

**Development & Code:**
- GitHub, GitLab, StackOverflow, Dev.to, Codepen, Replit

**Social Media:**
- Twitter, Facebook, Instagram, LinkedIn, TikTok, Pinterest

**Content Creation:**
- YouTube, Twitch, Medium, Blogger, WordPress, Tumblr

**Design & Art:**
- Behance, Dribbble, DeviantArt, ArtStation, 500px

**Gaming:**
- Steam, Twitch, Roblox, Chess.com, NameMC

**Security & Research:**
- HackerOne, Bugcrowd, TryHackMe, HackTheBox

And many more...

## Technical Details

- **Language**: C++17
- **HTTP Library**: libcurl
- **Build System**: CMake
- **Request Method**: HTTP HEAD requests for efficiency
- **Rate Limiting**: 100ms delay between requests
- **Timeout**: Configurable (default 10 seconds)
- **User Agent**: Custom OSINT-CLI identifier

## Performance

- **Average Speed**: ~1.5 requests per second (with rate limiting)
- **Memory Usage**: Minimal (~5MB)
- **Network Efficient**: Uses HEAD requests only
- **Concurrent**: Single-threaded with optimized timing

## Ethical Usage

⚠️ **Important Disclaimer**: This tool is designed for:
- Educational purposes
- Legitimate security research
- Personal username availability checking
- Authorized penetration testing

**Do NOT use for:**
- Stalking or harassment
- Unauthorized data collection
- Malicious activities
- Violating platform terms of service

## Contributing

Contributions are welcome! Areas for improvement:
- Additional platforms
- Performance optimizations
- Output format options
- Configuration file support

## License

This project is for educational purposes. Please respect platform terms of service and applicable laws.

## Troubleshooting

**Build Issues:**
- Ensure libcurl-dev is installed
- Check CMake version (3.10+)
- Verify C++17 compiler support

**Runtime Issues:**
- Check internet connectivity
- Some platforms may block automated requests
- Increase timeout for slow connections

**False Positives:**
- Some platforms return 200 for non-existent users
- Manual verification recommended for important results 