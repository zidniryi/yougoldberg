#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#ifdef NO_CURL
// Stub curl functions for compilation without libcurl
typedef void CURL;
typedef int CURLcode;
#define CURLE_OK 0
#define CURL_GLOBAL_DEFAULT 0
#define CURLOPT_URL 10000
#define CURLOPT_NOBODY 44
#define CURLOPT_TIMEOUT 13
#define CURLOPT_USERAGENT 10018
#define CURLOPT_FOLLOWLOCATION 52
#define CURLOPT_SSL_VERIFYPEER 64
#define CURLOPT_SSL_VERIFYHOST 81
#define CURLOPT_WRITEFUNCTION 20011
#define CURLOPT_WRITEDATA 10001
#define CURLINFO_RESPONSE_CODE 2097154

CURL *curl_easy_init(void) { return (CURL*)1; }
CURLcode curl_easy_setopt(CURL *curl, int option, ...) { return CURLE_OK; }
CURLcode curl_easy_perform(CURL *curl) { return CURLE_OK; }
CURLcode curl_easy_getinfo(CURL *curl, int info, ...) { return CURLE_OK; }
void curl_easy_cleanup(CURL *curl) {}
const char *curl_easy_strerror(CURLcode errornum) { return "OK"; }
int curl_global_init(long flags) { return CURLE_OK; }
void curl_global_cleanup(void) {}
#else
#include <curl/curl.h>
#endif
#include <cstdio>
#include <memory>
#include <iomanip>
#include <chrono>
#include <thread>
#include "platforms.hpp"

// ANSI color codes for better output formatting
#define RESET_COLOR   "\033[0m"
#define GREEN_COLOR   "\033[32m"
#define RED_COLOR     "\033[31m"
#define YELLOW_COLOR  "\033[33m"
#define BLUE_COLOR    "\033[34m"
#define MAGENTA_COLOR "\033[35m"
#define CYAN_COLOR    "\033[36m"

struct FoundProfile {
    std::string platform;
    std::string url;
    long responseCode;
};

// Callback function to handle response data (we don't need the content)
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* userp) {
    size_t totalSize = size * nmemb;
    userp->append((char*)contents, totalSize);
    return totalSize;
}

class OSINTChecker {
private:
    CURL* curl;
    bool verbose;
    int timeout;
    
public:
    OSINTChecker(bool verboseMode = false, int timeoutSecs = 10) 
        : curl(nullptr), verbose(verboseMode), timeout(timeoutSecs) {
        curl_global_init(CURL_GLOBAL_DEFAULT);
        curl = curl_easy_init();
        
        if (curl) {
            // Set common curl options
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
            curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
            curl_easy_setopt(curl, CURLOPT_TIMEOUT, timeout);
            curl_easy_setopt(curl, CURLOPT_USERAGENT, "Mozilla/5.0 (compatible; OSINT-CLI/1.0)");
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
            curl_easy_setopt(curl, CURLOPT_NOBODY, 1L); // HEAD request only
        }
    }
    
    ~OSINTChecker() {
        if (curl) {
            curl_easy_cleanup(curl);
        }
        curl_global_cleanup();
    }
    
    bool checkURL(const std::string& url, long& responseCode) {
        if (!curl) return false;
        
        std::string responseBuffer;
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
        
        CURLcode res = curl_easy_perform(curl);
        
        if (res != CURLE_OK) {
            if (verbose) {
                std::cout << RED_COLOR << "  ✗ CURL Error: " << curl_easy_strerror(res) << RESET_COLOR << std::endl;
            }
            return false;
        }
        
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &responseCode);
        return true;
    }
    
    std::vector<FoundProfile> searchUsername(const std::string& username) {
        std::vector<FoundProfile> foundProfiles;
        auto platforms = getPlatforms();
        
        std::cout << CYAN_COLOR << "\n🔍 Searching for username: " << YELLOW_COLOR << username << RESET_COLOR << std::endl;
        std::cout << BLUE_COLOR << "📊 Checking " << platforms.size() << " platforms...\n" << RESET_COLOR << std::endl;
        
        int current = 0;
        for (const auto& platform : platforms) {
            current++;
            
            // Format URL with username
            std::string formattedUrl;
            size_t bufferSize = platform.second.length() + username.length() + 1;
            char* buffer = new char[bufferSize];
            snprintf(buffer, bufferSize, platform.second.c_str(), username.c_str());
            formattedUrl = buffer;
            delete[] buffer;
            
            // Progress indicator
            std::cout << "\r" << MAGENTA_COLOR << "Progress: [" << current << "/" << platforms.size() << "] " 
                      << "Checking " << platform.first << "..." << RESET_COLOR << std::flush;
            
            long responseCode = 0;
            if (checkURL(formattedUrl, responseCode)) {
                if (verbose) {
                    std::cout << "\n  " << platform.first << " -> " << responseCode << " (" << formattedUrl << ")";
                }
                
                // Consider profile found if response is 200
                if (responseCode == 200) {
                    foundProfiles.push_back({platform.first, formattedUrl, responseCode});
                    std::cout << "\n" << GREEN_COLOR << "  ✓ FOUND: " << platform.first << RESET_COLOR << std::endl;
                }
            }
            
            // Small delay to avoid overwhelming servers
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
        
        std::cout << "\n" << std::endl;
        return foundProfiles;
    }
};

void printBanner() {
    std::cout << CYAN_COLOR << R"(


    ██    ██  ██████  ██    ██ 
     ██  ██  ██    ██ ██    ██ 
      ████   ██    ██ ██    ██ 
       ██    ██    ██ ██    ██
       ██     ██████   ██████  	
                                                            
 🔍 yougoldberg OSINT Username Discovery Tool 🔍            
 🔍 HELLO YOU! 🔍            
              Version 1.0                             

)" << RESET_COLOR << std::endl;
}

void printUsage(const char* programName) {
    std::cout << YELLOW_COLOR << "\nUsage: " << RESET_COLOR << programName << " [OPTIONS] <username>\n";
    std::cout << "\nOptions:\n";
    std::cout << "  -v, --verbose    Enable verbose output\n";
    std::cout << "  -t, --timeout    Set timeout in seconds (default: 10)\n";
    std::cout << "  -j, --json       Export results to JSON file\n";
    std::cout << "  -o, --output     Export results to TXT file\n";
    std::cout << "  -h, --help       Show this help message\n";
    std::cout << "\nExample:\n";
    std::cout << "  " << programName << " johndoe\n";
    std::cout << "  " << programName << " -v -t 15 johndoe\n";
    std::cout << "  " << programName << " -j johndoe\n";
    std::cout << "  " << programName << " -o results.txt johndoe\n" << std::endl;
}

void printResults(const std::vector<FoundProfile>& profiles) {
    if (profiles.empty()) {
        std::cout << RED_COLOR << "❌ No profiles found!" << RESET_COLOR << std::endl;
        return;
    }
    
    std::cout << GREEN_COLOR << "\n🎯 Found " << profiles.size() << " profile(s):\n" << RESET_COLOR << std::endl;
    std::cout << "┌─────────────────────────┬────────────────────────────────────────────────────────┐\n";
    std::cout << "│ " << CYAN_COLOR << std::left << std::setw(23) << "Platform" << RESET_COLOR << " │ " 
              << CYAN_COLOR << "URL" << RESET_COLOR << std::setw(53) << " " << "│\n";
    std::cout << "├─────────────────────────┼────────────────────────────────────────────────────────┤\n";
    
    for (const auto& profile : profiles) {
        std::cout << "│ " << GREEN_COLOR << std::left << std::setw(23) << profile.platform << RESET_COLOR << " │ ";
        
        if (profile.url.length() > 54) {
            std::cout << profile.url.substr(0, 51) << "..." << " │\n";
        } else {
            std::cout << std::left << std::setw(54) << profile.url << " │\n";
        }
    }
    
    std::cout << "└─────────────────────────┴────────────────────────────────────────────────────────┘\n" << std::endl;
}

void exportToJSON(const std::vector<FoundProfile>& profiles, const std::string& username) {
    std::string filename = username + "_results.json";
    std::ofstream file(filename);
    
    if (!file.is_open()) {
        std::cerr << RED_COLOR << "Error: Could not create JSON file " << filename << RESET_COLOR << std::endl;
        return;
    }
    
    file << "{\n";
    file << "  \"username\": \"" << username << "\",\n";
    file << "  \"search_date\": \"" << std::chrono::system_clock::now().time_since_epoch().count() << "\",\n";
    file << "  \"total_found\": " << profiles.size() << ",\n";
    file << "  \"profiles\": [\n";
    
    for (size_t i = 0; i < profiles.size(); i++) {
        file << "    {\n";
        file << "      \"platform\": \"" << profiles[i].platform << "\",\n";
        file << "      \"url\": \"" << profiles[i].url << "\",\n";
        file << "      \"response_code\": " << profiles[i].responseCode << "\n";
        file << "    }";
        if (i < profiles.size() - 1) file << ",";
        file << "\n";
    }
    
    file << "  ]\n";
    file << "}\n";
    file.close();
    
    std::cout << GREEN_COLOR << "📄 Results exported to: " << filename << RESET_COLOR << std::endl;
}

void exportToTXT(const std::vector<FoundProfile>& profiles, const std::string& username, const std::string& outputFile) {
    std::ofstream file(outputFile);
    
    if (!file.is_open()) {
        std::cerr << RED_COLOR << "Error: Could not create TXT file " << outputFile << RESET_COLOR << std::endl;
        return;
    }
    
    file << "YouGoldberg OSINT Results\n";
    file << "========================\n\n";
    file << "Username: " << username << "\n";
    file << "Search Date: " << std::chrono::system_clock::now().time_since_epoch().count() << "\n";
    file << "Total Profiles Found: " << profiles.size() << "\n\n";
    
    if (profiles.empty()) {
        file << "No profiles found for this username.\n";
    } else {
        file << "Found Profiles:\n";
        file << "---------------\n\n";
        
        for (const auto& profile : profiles) {
            file << "Platform: " << profile.platform << "\n";
            file << "URL: " << profile.url << "\n";
            file << "Response Code: " << profile.responseCode << "\n";
            file << "---\n\n";
        }
    }
    
    file.close();
    
    std::cout << GREEN_COLOR << "📄 Results exported to: " << outputFile << RESET_COLOR << std::endl;
}

int main(int argc, char* argv[]) {
    bool verbose = false;
    int timeout = 10;
    std::string username;
    bool exportJSON = false;
    std::string outputFile = "";
    
    // Parse command line arguments
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        
        if (arg == "-h" || arg == "--help") {
            printBanner();
            printUsage(argv[0]);
            return 0;
        } else if (arg == "-v" || arg == "--verbose") {
            verbose = true;
        } else if (arg == "-t" || arg == "--timeout") {
            if (i + 1 < argc) {
                timeout = std::atoi(argv[++i]);
                if (timeout <= 0) {
                    std::cerr << RED_COLOR << "Error: Timeout must be a positive integer" << RESET_COLOR << std::endl;
                    return 1;
                }
            } else {
                std::cerr << RED_COLOR << "Error: --timeout requires a value" << RESET_COLOR << std::endl;
                return 1;
            }
        } else if (arg == "-j" || arg == "--json") {
            exportJSON = true;
        } else if (arg == "-o" || arg == "--output") {
            if (i + 1 < argc) {
                outputFile = argv[++i];
            } else {
                std::cerr << RED_COLOR << "Error: --output requires a filename" << RESET_COLOR << std::endl;
                return 1;
            }
        } else if (arg[0] != '-') {
            username = arg;
        } else {
            std::cerr << RED_COLOR << "Error: Unknown option " << arg << RESET_COLOR << std::endl;
            printUsage(argv[0]);
            return 1;
        }
    }
    
    // Show banner
    printBanner();
    
    // Check if username is provided
    if (username.empty()) {
        std::cerr << RED_COLOR << "Error: Username is required!" << RESET_COLOR << std::endl;
        printUsage(argv[0]);
        return 1;
    }
    
    // Validate username
    if (username.length() < 2 || username.length() > 50) {
        std::cerr << RED_COLOR << "Error: Username must be between 2 and 50 characters!" << RESET_COLOR << std::endl;
        return 1;
    }
    
    // Create OSINT checker instance
    OSINTChecker checker(verbose, timeout);
    
    // Start search
    auto startTime = std::chrono::high_resolution_clock::now();
    auto foundProfiles = checker.searchUsername(username);
    auto endTime = std::chrono::high_resolution_clock::now();
    
    // Calculate duration
    auto duration = std::chrono::duration_cast<std::chrono::seconds>(endTime - startTime);
    
    // Print results
    printResults(foundProfiles);
    
    // Export results if requested
    if (exportJSON) {
        exportToJSON(foundProfiles, username);
    }
    
    if (!outputFile.empty()) {
        exportToTXT(foundProfiles, username, outputFile);
    }
    
    std::cout << BLUE_COLOR << "⏱️  Search completed in " << duration.count() << " seconds" << RESET_COLOR << std::endl;
    std::cout << YELLOW_COLOR << "⚠️  Remember: This tool is for educational and legitimate research purposes only!" << RESET_COLOR << std::endl;
    
    return 0;
} 