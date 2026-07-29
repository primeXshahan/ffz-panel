<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>KeyAuth - Installation</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, Arial, sans-serif; background: #0f0f1a; color: #fff; display: flex; justify-content: center; padding: 40px 20px; }
.container { max-width: 600px; width: 100%; }
h1 { color: #00ff88; font-size: 28px; margin-bottom: 8px; }
.subtitle { color: #888; margin-bottom: 30px; }
.card { background: #1a1a2e; border-radius: 12px; padding: 25px; margin-bottom: 20px; border: 1px solid #2a2a4a; }
.card h2 { color: #00ff88; font-size: 18px; margin-bottom: 15px; }
.status-item { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #2a2a4a; }
.status-item:last-child { border-bottom: none; }
.label { color: #aaa; }
.badge { padding: 3px 12px; border-radius: 20px; font-size: 13px; }
.badge.ok { background: #00ff8822; color: #00ff88; border: 1px solid #00ff8844; }
.badge.fail { background: #ff444422; color: #ff4444; border: 1px solid #ff444444; }
.badge.warn { background: #ffaa0022; color: #ffaa00; border: 1px solid #ffaa0044; }
pre { background: #0a0a15; padding: 15px; border-radius: 8px; overflow-x: auto; font-size: 13px; margin-top: 10px; }
a { color: #00ff88; }
input, button { font-family: inherit; }
</style>
</head>
<body>
<div class="container">
    <h1>🔐 KeyAuth Server</h1>
    <p class="subtitle">Installation & Status Check</p>
    
    <div class="card">
        <h2>📋 System Status</h2>
        
        <?php
        require_once __DIR__ . '/config.php';
        
        $status = [];
        $all_ok = true;
        
        // PHP version
        $php_ok = version_compare(PHP_VERSION, '7.0', '>=');
        $status[] = ['PHP Version', PHP_VERSION, $php_ok ? 'ok' : 'fail'];
        if (!$php_ok) $all_ok = false;
        
        // SQLite support
        $sqlite_ok = extension_loaded('pdo_sqlite');
        $status[] = ['SQLite (PDO)', $sqlite_ok ? 'Available' : 'Missing!', $sqlite_ok ? 'ok' : 'fail'];
        if (!$sqlite_ok) $all_ok = false;
        
        // OpenSSL
        $ssl_ok = extension_loaded('openssl');
        $status[] = ['OpenSSL', $ssl_ok ? 'Available' : 'Missing!', $ssl_ok ? 'ok' : 'warn'];
        
        // JSON
        $json_ok = extension_loaded('json');
        $status[] = ['JSON', $json_ok ? 'Available' : 'Missing!', $json_ok ? 'ok' : 'fail'];
        if (!$json_ok) $all_ok = false;
        
        // CURL
        $curl_ok = extension_loaded('curl');
        $status[] = ['cURL', $curl_ok ? 'Available' : 'Not available', $curl_ok ? 'ok' : 'warn'];
        
        // Database file
        $db_exists = file_exists(DB_PATH);
        $db_writable = is_writable(dirname(DB_PATH));
        $status[] = ['Database', $db_exists ? 'Exists' : 'Will be created', $db_writable ? 'ok' : 'fail'];
        if (!$db_writable) $all_ok = false;
        
        // Admin secret check
        $default_secret = (ADMIN_SECRET === 'ChangeThisToYourSecretKey2024');
        $status[] = ['Admin Secret', $default_secret ? '⚠ Using DEFAULT - CHANGE IT!' : '✅ Custom set', $default_secret ? 'warn' : 'ok'];
        
        // SMTP
        $status[] = ['SMTP (Email)', SMTP_ENABLED ? 'Enabled' : 'Disabled', SMTP_ENABLED ? 'ok' : 'warn'];
        
        foreach ($status as $s):
        ?>
        <div class="status-item">
            <span class="label"><?= htmlspecialchars($s[0]) ?></span>
            <span>
                <span style="color:#aaa;margin-right:8px"><?= htmlspecialchars($s[1]) ?></span>
                <span class="badge <?= $s[2] ?>"><?= $s[2] ?></span>
            </span>
        </div>
        <?php endforeach; ?>
    </div>
    
    <?php if ($all_ok): ?>
    <div class="card" style="border-color: #00ff8844; background: #00ff8810;">
        <h2>✅ Installation Complete!</h2>
        <p>Database will be created automatically on first API call.</p>
        <pre>// Test your API:
curl "<?= (isset($_SERVER['HTTPS']) ? 'https' : 'http') ?>://<?= $_SERVER['HTTP_HOST'] ?><?= dirname($_SERVER['SCRIPT_NAME']) ?>/index.php?action=ping"</pre>
    </div>
    <?php else: ?>
    <div class="card" style="border-color: #ff444444; background: #ff444410;">
        <h2>❌ Some Requirements Missing</h2>
        <p>Please install the missing PHP extensions to continue.</p>
    </div>
    <?php endif; ?>
    
    <div class="card">
        <h2>📖 API Endpoints</h2>
        <pre>
🔍 Validate Key:
  GET index.php?action=validate&key=XXXX-XXXX-XXXX-XXXX&udid=DEVICE_UDID

🔑 Generate Key (Admin):
  GET index.php?action=generate&admin_key=YOUR_SECRET&udid=DEVICE_UDID

⛔ Revoke Key (Admin):
  GET index.php?action=revoke&admin_key=YOUR_SECRET&key=XXXX-XXXX-XXXX-XXXX

📋 List Keys (Admin):
  GET index.php?action=list&admin_key=YOUR_SECRET

📊 View Logs (Admin):
  GET index.php?action=logs&admin_key=YOUR_SECRET

📧 Send Key via Email (Admin):
  GET index.php?action=send_email&admin_key=YOUR_SECRET&key=KEY&email=user@example.com

🏓 Ping / Health Check:
  GET index.php?action=ping
        </pre>
    </div>
    
    <div class="card">
        <h2>⚙️ Configuration</h2>
        <p>Edit <code>config.php</code> to change:</p>
        <pre>define('ADMIN_SECRET', 'YourSecretKey');    // Admin API key
define('MASTER_SECRET', 'YourKey');         // Must match iOS KeyAuth.mm
define('SMTP_ENABLED', false);              // Set true for email</pre>
    </div>
</div>
</body>
</html>
