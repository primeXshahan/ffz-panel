# FFZ KeyAuth Server - Complete Key Management System

## Architecture

```
                    ┌──────────────────────┐
                    │   PHP API Server     │
                    │   (SQLite Database)   │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ C++ Admin    │ │ Web Admin    │ │ iOS Tweak    │
    │ (Windows EXE)│ │ (Browser)    │ │ (KeyAuth.mm) │
    │ PC           │ │ PC / Phone   │ │ iPhone       │
    └──────────────┘ └──────────────┘ └──────────────┘
```

## 📁 File Structure

```
KeyAuthServer/
├── api/
│   ├── config.php        # Configuration (secrets, DB, SMTP)
│   ├── index.php         # Main API endpoints
│   └── install.php       # Web-based setup & status check
├── admin/
│   └── index.html        # Web admin panel (single HTML file)
├── CppAdmin/
│   └── KeyAuthAdmin.cpp  # C++ Windows EXE admin tool
└── README.md
```

---

## 🚀 Option 1: Host on Free Web Hosting (Easiest!)

1. Sign up at **InfinityFree**, **000WebHost**, or **AwardSpace** (all free)
2. Upload the entire `KeyAuthServer/api/` folder to your server
3. Visit `https://yoursite.com/api/install.php` to check setup
4. Edit `config.php` → change `ADMIN_SECRET` and `MASTER_SECRET`

Your API will be at: `https://yoursite.com/api/index.php`

---

## 🚀 Option 2: Host on Your PC (Localhost)

### Install XAMPP (Windows):
1. Download XAMPP from https://www.apachefriends.org/
2. Install and start Apache
3. Copy `KeyAuthServer/api/` folder to `C:\xampp\htdocs\keyauth\`
4. Visit `http://localhost/keyauth/api/install.php`
5. Your API URL: `http://localhost/keyauth/api/index.php`

### Install PHP Built-in Server (No XAMPP needed):
```bash
php -S 0.0.0.0:8000 -t KeyAuthServer/api/
```
Your API URL: `http://localhost:8000/index.php`

---

## 🔑 Using the Web Admin Panel

1. Open `KeyAuthServer/admin/index.html` in any browser (PC or Phone)
2. Enter your API URL (e.g., `https://yoursite.com/api/index.php`)
3. Enter your Admin Secret Key
4. Click "Test Connection"

From the web panel you can:
- Generate keys (enter device UDID)
- View all keys with status
- Revoke keys
- Send keys via email
- View activity logs

---

## 💻 Using the C++ Windows EXE

### Compile:
```bash
# Visual Studio:
cl KeyAuthAdmin.cpp /EHsc /Fe:KeyAuthAdmin.exe

# MinGW/GCC:
g++ KeyAuthAdmin.cpp -lwinhttp -o KeyAuthAdmin.exe
```

### Features:
1. 🔑 Generate Key - Create new license keys
2. 📋 List All Keys - View all keys with details
3. ⛔ Revoke Key - Deactivate a key
4. 📊 View Logs - See validation activity
5. 🔌 Test Connection - Check API connectivity
6. ⚙️ Settings - Configure API URL and admin key

Settings are auto-saved to `keyauth_config.txt`.

---

## 📱 iOS Tweak Integration

1. Upload the PHP API to a server
2. Edit `Helper/KeyAuth.mm`:
   - Set `API_SERVER_URL` to your hosted API URL
   - Set `KEYAUTH_SECRET` to match `MASTER_SECRET` in `config.php`
3. Build the tweak with Theos
4. The tweak will:
   - First try to validate via API server
   - Fall back to local validation if server is unreachable

---

## 📧 Sending Keys via Gmail

1. Edit `KeyAuthServer/api/config.php`
2. Set `SMTP_ENABLED = true`
3. Enter your Gmail credentials (use App Password!)
4. From Web Admin or C++ EXE, choose "Send Email"

### How to get Gmail App Password:
1. Go to Google Account → Security → 2-Step Verification → Enable
2. Go to App Passwords → Select "Mail" + "Windows Computer"
3. Copy the 16-character password

---

## 🔐 Security Tips

1. **Change ALL default secrets** before going live
2. Use HTTPS for your API server
3. Keep `ADMIN_SECRET` private - it controls everything
4. Each key is device-specific (one UDID = one key)
5. Revoke keys immediately if compromised
6. Change `MASTER_SECRET` to invalidate ALL existing keys

---

## 📡 API Endpoints Reference

| Endpoint | Description |
|----------|-------------|
| `?action=ping` | Health check |
| `?action=validate&key=KEY&udid=UDID` | Validate a key |
| `?action=generate&admin_key=SECRET&udid=UDID` | Generate new key |
| `?action=revoke&admin_key=SECRET&key=KEY` | Revoke a key |
| `?action=list&admin_key=SECRET` | List all keys |
| `?action=logs&admin_key=SECRET` | View activity logs |
| `?action=send_email&admin_key=SECRET&key=KEY&email=EMAIL` | Send key via email |

All endpoints return JSON: `{"success": true/false, ...}`
