# YouGoldberg - OSINT Username Discovery Tool 🔍

A fast and efficient C++ CLI tool for Open Source Intelligence (OSINT) that searches for usernames across 80+ popular platforms and services.

## Features

- 🚀 **Fast Multi-Platform Search**: Check username availability across 80+ platforms
- 🎯 **HTTP Status Verification**: Uses HEAD requests for efficient checking
- 🎨 **Beautiful CLI Interface**: Colored output with progress indicators
- ⚙️ **Configurable**: Adjustable timeout and verbose mode
- 🔒 **Responsible**: Built with rate limiting to respect server resources

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

1. **Clone or download the project**
2. **Navigate to project directory**
3. **Create build directory and compile:**

```bash
mkdir build
cd build
cmake ..
make
```

## Usage

### Basic Usage
```bash
./yougoldberg <username>
```

### Options
- `-v, --verbose` - Enable verbose output showing all checked URLs
- `-t, --timeout` - Set timeout in seconds (default: 10)
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

**Get help:**
```bash
./yougoldberg --help
```

## Sample Output

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ██    ██  ██████  ██    ██  ██████   ██████  ██      ██ ║
║     ██  ██  ██    ██ ██    ██ ██       ██    ██ ██      ██  ║
║      ████   ██    ██ ██    ██ ██   ███ ██    ██ ██      ██  ║
║       ██    ██    ██ ██    ██ ██    ██ ██    ██ ██      ██  ║
║       ██     ██████   ██████   ██████   ██████  ███████ ██  ║
║                                                              ║
║              🔍 OSINT Username Discovery Tool 🔍            ║
║                     Version 1.0                             ║
╚══════════════════════════════════════════════════════════════╝

🔍 Searching for username: techuser
📊 Checking 80 platforms...

Progress: [80/80] Checking Chess.com...
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

The tool checks 80+ platforms including:

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