// ============================================================
// KeyAuthAdmin.cpp - Windows C++ Key Management Tool
// ============================================================
// Compile on Windows with any C++ compiler:
//   Visual Studio: cl KeyAuthAdmin.cpp /EHsc /Fe:KeyAuthAdmin.exe
//   MinGW/GCC:     g++ KeyAuthAdmin.cpp -lwinhttp -o KeyAuthAdmin.exe
//
// No external dependencies - uses WinHTTP (built into Windows)
// ============================================================

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <winhttp.h>
#include <iostream>
#include <string>
#include <vector>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <fstream>

#pragma comment(lib, "winhttp.lib")

// ============================================================
// CONFIGURATION - Edit these!
// ============================================================
std::string API_URL = "http://localhost/api/index.php";
std::string ADMIN_KEY = "ChangeThisToYourSecretKey2024";

// ============================================================
// HTTP Client (WinHTTP)
// ============================================================
std::string httpGet(const std::string& url) {
    std::string result;
    HINTERNET hSession = NULL, hConnect = NULL, hRequest = NULL;
    
    // Parse URL
    URL_COMPONENTS urlComp = {0};
    urlComp.dwStructSize = sizeof(urlComp);
    urlComp.dwSchemeLength = -1;
    urlComp.dwHostNameLength = -1;
    urlComp.dwUrlPathLength = -1;
    urlComp.dwExtraInfoLength = -1;
    
    std::wstring wurl(url.begin(), url.end());
    WinHttpCrackUrl(wurl.c_str(), wurl.length(), 0, &urlComp);
    
    std::wstring hostName(urlComp.lpszHostName, urlComp.dwHostNameLength);
    std::wstring urlPath(urlComp.lpszUrlPath, urlComp.dwUrlPathLength);
    std::wstring extraInfo(urlComp.lpszExtraInfo, urlComp.dwExtraInfoLength);
    
    bool isSecure = (urlComp.nScheme == INTERNET_SCHEME_HTTPS);
    DWORD flags = isSecure ? WINHTTP_FLAG_SECURE : 0;
    
    hSession = WinHttpOpen(L"KeyAuthAdmin/1.0", WINHTTP_ACCESS_TYPE_DEFAULT_PROXY, NULL, NULL, 0);
    if (hSession) {
        hConnect = WinHttpConnect(hSession, hostName.c_str(), urlComp.nPort, 0);
        if (hConnect) {
            hRequest = WinHttpOpenRequest(hConnect, L"GET", (urlPath + extraInfo).c_str(), NULL, NULL, NULL, flags);
            if (hRequest) {
                if (WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0, NULL, 0, 0, 0)) {
                    if (WinHttpReceiveResponse(hRequest, NULL)) {
                        DWORD size = 0;
                        do {
                            if (!WinHttpQueryDataAvailable(hRequest, &size)) break;
                            if (size == 0) break;
                            
                            char* buffer = new char[size + 1];
                            DWORD downloaded = 0;
                            if (WinHttpReadData(hRequest, buffer, size, &downloaded)) {
                                buffer[downloaded] = 0;
                                result += buffer;
                            }
                            delete[] buffer;
                        } while (size > 0);
                    }
                }
            }
        }
    }
    
    if (hRequest) WinHttpCloseHandle(hRequest);
    if (hConnect) WinHttpCloseHandle(hConnect);
    if (hSession) WinHttpCloseHandle(hSession);
    
    return result;
}

// ============================================================
// Simple JSON Parser (minimal - just what we need)
// ============================================================
std::string jsonGetString(const std::string& json, const std::string& key) {
    std::string search = "\"" + key + "\":\"";
    size_t pos = json.find(search);
    if (pos == std::string::npos) {
        // Try with spaces
        search = "\"" + key + "\" : \"";
        pos = json.find(search);
        if (pos == std::string::npos) return "";
    }
    pos += search.length();
    size_t end = json.find("\"", pos);
    if (end == std::string::npos) return "";
    return json.substr(pos, end - pos);
}

bool jsonGetBool(const std::string& json) {
    return json.find("\"success\":true") != std::string::npos ||
           json.find("\"success\": true") != std::string::npos;
}

std::string jsonGetArray(const std::string& json, const std::string& key) {
    std::string search = "\"" + key + "\":[";
    size_t pos = json.find(search);
    if (pos == std::string::npos) return "";
    pos += search.length();
    int depth = 1;
    size_t end = pos;
    while (end < json.length() && depth > 0) {
        if (json[end] == '[') depth++;
        if (json[end] == ']') depth--;
        end++;
    }
    return json.substr(pos, end - pos - 1);
}

// ============================================================
// Console Helpers
// ============================================================
void setColor(int color) {
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), color);
}
// Colors: 2=green, 4=red, 6=yellow, 7=white, 11=cyan, 14=gold
void printGreen(const std::string& s) { setColor(2); std::cout << s; setColor(7); }
void printRed(const std::string& s) { setColor(4); std::cout << s; setColor(7); }
void printYellow(const std::string& s) { setColor(6); std::cout << s; setColor(7); }
void printCyan(const std::string& s) { setColor(11); std::cout << s; setColor(7); }

void clearScreen() {
    system("cls");
}

void printBanner() {
    std::cout << "\n";
    printGreen("  ╔══════════════════════════════════════════╗\n");
    printGreen("  ║      FFZ KeyAuth Admin Tool v1.0        ║\n");
    printGreen("  ╚══════════════════════════════════════════╝\n");
    std::cout << "\n";
}

void waitForKey() {
    std::cout << "\n  Press Enter to continue...";
    std::cin.get();
    std::cin.clear();
}

// ============================================================
// API Call Functions
// ============================================================
bool callAPI(const std::string& action, const std::string& params, std::string& response) {
    std::string url = API_URL + "?action=" + action + "&admin_key=" + ADMIN_KEY + params;
    response = httpGet(url);
    if (response.empty()) {
        printRed("  ❌ Failed to connect to server!\n");
        return false;
    }
    return true;
}

void menuGenerateKey() {
    std::string udid, expiry, email, notes;
    
    std::cout << "\n";
    printCyan("  ── Generate New Key ──\n");
    std::cout << "\n";
    
    std::cout << "  Device UDID: ";
    std::getline(std::cin, udid);
    
    std::cout << "  Expiry date (YYYY-MM-DD, or leave empty): ";
    std::getline(std::cin, expiry);
    
    std::cout << "  User email (optional): ";
    std::getline(std::cin, email);
    
    std::cout << "  Notes: ";
    std::getline(std::cin, notes);
    
    if (udid.empty()) {
        printRed("  ❌ Device UDID is required!\n");
        return;
    }
    
    std::string params = "&udid=" + udid;
    if (!expiry.empty()) params += "&expiry=" + expiry;
    if (!email.empty()) params += "&email=" + email;
    if (!notes.empty()) params += "&notes=" + notes;
    
    std::cout << "  ⏳ Generating key...\n";
    
    std::string response;
    if (callAPI("generate", params, response)) {
        if (jsonGetBool(response)) {
            std::string key = jsonGetString(response, "key");
            std::string dev = jsonGetString(response, "device_udid");
            std::string exp = jsonGetString(response, "expires_at");
            
            std::cout << "\n";
            printGreen("  ✅ KEY GENERATED!\n");
            std::cout << "\n";
            setColor(14);
            std::cout << "  🔑 " << key << "\n";
            setColor(7);
            std::cout << "  Device: " << dev.substr(0, 8) << "..." << "\n";
            std::cout << "  Expiry: " << (exp.empty() ? "Never" : exp) << "\n";
            std::cout << "\n";
        } else {
            std::string err = jsonGetString(response, "error");
            printRed("  ❌ " + (err.empty() ? "Unknown error" : err) + "\n");
        }
    }
}

void menuListKeys() {
    std::cout << "\n";
    printCyan("  ── Loading Keys ──\n");
    
    std::string response;
    if (callAPI("list", "", response)) {
        if (jsonGetBool(response)) {
            // Parse the keys array (simple approach)
            std::string keysArray = jsonGetArray(response, "keys");
            
            if (keysArray.empty() || keysArray == "[]") {
                printYellow("  No keys found.\n");
                return;
            }
            
            // Count keys (count "license_key" occurrences)
            int count = 0;
            size_t pos = 0;
            while ((pos = keysArray.find("\"license_key\"", pos)) != std::string::npos) {
                count++;
                pos += 13;
            }
            
            std::cout << "\n";
            printGreen("  ── All Keys (" + std::to_string(count) + " total) ──\n");
            std::cout << "\n";
            
            // Simple parsing - extract each key object
            pos = 0;
            int index = 1;
            while (pos < keysArray.length()) {
                // Find start of object
                size_t objStart = keysArray.find("{", pos);
                if (objStart == std::string::npos) break;
                size_t objEnd = keysArray.find("}", objStart);
                if (objEnd == std::string::npos) break;
                
                std::string obj = keysArray.substr(objStart, objEnd - objStart + 1);
                
                std::string k = jsonGetString(obj, "license_key");
                std::string d = jsonGetString(obj, "device_udid");
                std::string s = jsonGetString(obj, "status");
                std::string e = jsonGetString(obj, "expires_at");
                std::string em = jsonGetString(obj, "email");
                std::string c = jsonGetString(obj, "created_at");
                
                // Format key with dashes
                std::string fmtKey = k;
                if (fmtKey.length() >= 16) {
                    fmtKey = k.substr(0,4) + "-" + k.substr(4,4) + "-" + k.substr(8,4) + "-" + k.substr(12,4);
                }
                
                std::cout << "  " << index++ << ". " << fmtKey << "\n";
                std::cout << "     Status: " << s;
                if (!e.empty()) std::cout << " | Expires: " << e;
                std::cout << "\n";
                if (!d.empty()) std::cout << "     Device: " << d.substr(0, 20) << (d.length() > 20 ? "..." : "") << "\n";
                if (!em.empty()) std::cout << "     Email: " << em << "\n";
                std::cout << "     Created: " << c << "\n\n";
                
                pos = objEnd + 1;
            }
        } else {
            std::string err = jsonGetString(response, "error");
            printRed("  ❌ " + (err.empty() ? "Unknown error" : err) + "\n");
        }
    }
}

void menuRevokeKey() {
    std::string key;
    
    std::cout << "\n";
    printCyan("  ── Revoke Key ──\n");
    std::cout << "\n";
    std::cout << "  Enter key to revoke: ";
    std::getline(std::cin, key);
    
    if (key.empty()) {
        printRed("  ❌ Key is required!\n");
        return;
    }
    
    std::cout << "  ⏳ Revoking key...\n";
    
    std::string response;
    if (callAPI("revoke", "&key=" + key, response)) {
        if (jsonGetBool(response)) {
            printGreen("  ✅ Key revoked successfully!\n");
        } else {
            std::string err = jsonGetString(response, "error");
            printRed("  ❌ " + (err.empty() ? "Unknown error" : err) + "\n");
        }
    }
}

void menuViewLogs() {
    std::cout << "\n";
    printCyan("  ── Loading Logs ──\n");
    
    std::string response;
    if (callAPI("logs", "", response)) {
        if (jsonGetBool(response)) {
            std::string logsArray = jsonGetArray(response, "logs");
            
            if (logsArray.empty() || logsArray == "[]") {
                printYellow("  No logs found.\n");
                return;
            }
            
            int count = 0;
            size_t pos = 0;
            while ((pos = logsArray.find("\"license_key\"", pos)) != std::string::npos) {
                count++;
                pos += 13;
            }
            
            std::cout << "\n";
            printGreen("  ── Recent Activity (" + std::to_string(count) + " entries) ──\n");
            std::cout << "\n";
            
            pos = 0;
            int index = 1;
            while (pos < logsArray.length()) {
                size_t objStart = logsArray.find("{", pos);
                if (objStart == std::string::npos) break;
                size_t objEnd = logsArray.find("}", objStart);
                if (objEnd == std::string::npos) break;
                
                std::string obj = logsArray.substr(objStart, objEnd - objStart + 1);
                
                std::string time = jsonGetString(obj, "created_at");
                std::string action = jsonGetString(obj, "action");
                std::string key = jsonGetString(obj, "license_key");
                std::string ip = jsonGetString(obj, "ip_address");
                std::string dev = jsonGetString(obj, "device_udid");
                
                std::cout << "  " << index++ << ". [" << action << "] " << time << "\n";
                std::cout << "     Key: " << key.substr(0, 8) << "..." << "\n";
                if (!ip.empty()) std::cout << "     IP: " << ip << "\n";
                if (!dev.empty()) std::cout << "     Device: " << dev.substr(0, 8) << "..." << "\n";
                
                pos = objEnd + 1;
            }
        } else {
            printRed("  ❌ Failed to load logs\n");
        }
    }
}

void menuTestConnection() {
    std::cout << "  ⏳ Testing connection...\n";
    
    std::string response;
    if (callAPI("ping", "", response)) {
        if (jsonGetBool(response)) {
            std::string ver = jsonGetString(response, "version");
            std::string msg = jsonGetString(response, "message");
            printGreen("  ✅ " + msg + " (v" + ver + ")\n");
        } else {
            printRed("  ❌ Server error\n");
        }
    }
}

void menuSettings() {
    std::string input;
    
    std::cout << "\n";
    printCyan("  ── Settings ──\n");
    std::cout << "\n";
    std::cout << "  Current API URL: " << API_URL << "\n";
    std::cout << "  Enter new API URL (or empty to keep): ";
    std::getline(std::cin, input);
    if (!input.empty()) API_URL = input;
    
    std::cout << "  Current Admin Key: " << ADMIN_KEY.substr(0, 6) << "...\n";
    std::cout << "  Enter new Admin Key (or empty to keep): ";
    std::getline(std::cin, input);
    if (!input.empty()) ADMIN_KEY = input;
    
    // Save settings to file
    std::ofstream file("keyauth_config.txt");
    if (file.is_open()) {
        file << API_URL << "\n" << ADMIN_KEY;
        file.close();
        printGreen("  ✅ Settings saved!\n");
    } else {
        printYellow("  ⚠ Could not save settings to file\n");
    }
}

void loadSettings() {
    std::ifstream file("keyauth_config.txt");
    if (file.is_open()) {
        std::getline(file, API_URL);
        std::getline(file, ADMIN_KEY);
        file.close();
    }
}

// ============================================================
// Main Menu
// ============================================================
int main() {
    loadSettings();
    
    while (true) {
        clearScreen();
        printBanner();
        
        printGreen("  API: "); std::cout << API_URL << "\n";
        std::cout << "\n";
        
        std::cout << "  [1] 🔑  Generate Key\n";
        std::cout << "  [2] 📋  List All Keys\n";
        std::cout << "  [3] ⛔  Revoke Key\n";
        std::cout << "  [4] 📊  View Logs\n";
        std::cout << "  [5] 🔌  Test Connection\n";
        std::cout << "  [6] ⚙️   Settings\n";
        std::cout << "  [0] ❌  Exit\n";
        std::cout << "\n";
        std::cout << "  Choose option: ";
        
        std::string choice;
        std::getline(std::cin, choice);
        
        if (choice == "1") { menuGenerateKey(); waitForKey(); }
        else if (choice == "2") { menuListKeys(); waitForKey(); }
        else if (choice == "3") { menuRevokeKey(); waitForKey(); }
        else if (choice == "4") { menuViewLogs(); waitForKey(); }
        else if (choice == "5") { menuTestConnection(); waitForKey(); }
        else if (choice == "6") { menuSettings(); waitForKey(); }
        else if (choice == "0") { 
            printGreen("\n  Goodbye!\n\n");
            break; 
        }
        else {
            printRed("  Invalid option!\n");
            waitForKey();
        }
    }
    
    return 0;
}
