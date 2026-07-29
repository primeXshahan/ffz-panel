<?php
// ============================================================
// KeyAuth API Server - Main Entry Point
// ============================================================
// Host this on any PHP-supported web server!
// ============================================================

require_once __DIR__ . '/config.php';

// Set headers
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: " . API_ACCESS_CONTROL);
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get action from query string or POST body
$action = $_REQUEST['action'] ?? '';

// Initialize database
function initDB() {
    try {
        $db = new PDO('sqlite:' . DB_PATH);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        $db->exec("CREATE TABLE IF NOT EXISTS keys (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            license_key TEXT UNIQUE NOT NULL,
            device_udid TEXT DEFAULT '',
            status TEXT DEFAULT 'active',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            activated_at DATETIME,
            expires_at DATETIME,
            email TEXT DEFAULT '',
            notes TEXT DEFAULT ''
        )");
        
        $db->exec("CREATE TABLE IF NOT EXISTS logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            license_key TEXT NOT NULL,
            action TEXT NOT NULL,
            device_udid TEXT DEFAULT '',
            ip_address TEXT DEFAULT '',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )");
        
        return $db;
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
        exit;
    }
}

// Validate admin request
function validateAdmin() {
    $admin_key = $_REQUEST['admin_key'] ?? '';
    if ($admin_key !== ADMIN_SECRET) {
        http_response_code(403);
        echo json_encode(['success' => false, 'error' => 'Invalid admin key']);
        exit;
    }
}

// Generate HMAC-SHA256 key (matching iOS implementation)
function generateLicenseKey($deviceUDID) {
    $hash = hash_hmac('sha256', $deviceUDID, MASTER_SECRET);
    $keyPart = strtoupper(substr($hash, 0, 16));
    return substr($keyPart, 0, 4) . '-' . 
           substr($keyPart, 4, 4) . '-' . 
           substr($keyPart, 8, 4) . '-' . 
           substr($keyPart, 12, 4);
}

// Send email via SMTP
function sendEmail($to, $subject, $body) {
    if (!SMTP_ENABLED) {
        return ['success' => false, 'error' => 'SMTP not enabled'];
    }
    
    // Simple SMTP implementation
    $headers = "MIME-Version: 1.0\r\n";
    $headers .= "Content-type: text/plain; charset=UTF-8\r\n";
    $headers .= "From: " . SMTP_FROM_NAME . " <" . SMTP_FROM_EMAIL . ">\r\n";
    
    $success = mail($to, $subject, $body, $headers, "-f " . SMTP_FROM_EMAIL);
    
    if ($success) {
        return ['success' => true];
    } else {
        // Try SMTP directly if mail() fails
        return sendSMTPDirect($to, $subject, $body);
    }
}

// Direct SMTP (for Gmail)
function sendSMTPDirect($to, $subject, $body) {
    try {
        $smtpconn = fsockopen(SMTP_HOST, SMTP_PORT, $errno, $errstr, 30);
        if (!$smtpconn) return ['success' => false, 'error' => $errstr];
        
        $response = fgets($smtpconn, 515);
        
        fputs($smtpconn, "EHLO KeyAuth\r\n");
        while ($line = fgets($smtpconn, 515)) {
            if (substr($line, 3, 1) == ' ') break;
        }
        
        fputs($smtpconn, "STARTTLS\r\n");
        fgets($smtpconn, 515);
        
        stream_socket_enable_crypto($smtpconn, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);
        
        fputs($smtpconn, "EHLO KeyAuth\r\n");
        while ($line = fgets($smtpconn, 515)) {
            if (substr($line, 3, 1) == ' ') break;
        }
        
        fputs($smtpconn, "AUTH LOGIN\r\n");
        fgets($smtpconn, 515);
        
        fputs($smtpconn, base64_encode(SMTP_USERNAME) . "\r\n");
        fgets($smtpconn, 515);
        
        fputs($smtpconn, base64_encode(SMTP_PASSWORD) . "\r\n");
        $auth_response = fgets($smtpconn, 515);
        
        if (substr($auth_response, 0, 3) != '235') {
            fclose($smtpconn);
            return ['success' => false, 'error' => 'SMTP auth failed'];
        }
        
        fputs($smtpconn, "MAIL FROM: <" . SMTP_FROM_EMAIL . ">\r\n");
        fgets($smtpconn, 515);
        
        fputs($smtpconn, "RCPT TO: <" . $to . ">\r\n");
        fgets($smtpconn, 515);
        
        $headers = "From: " . SMTP_FROM_NAME . " <" . SMTP_FROM_EMAIL . ">\r\n";
        fputs($smtpconn, "DATA\r\n");
        fgets($smtpconn, 515);
        
        fputs($smtpconn, "Subject: " . $subject . "\r\n");
        fputs($smtpconn, $headers);
        fputs($smtpconn, "\r\n" . $body . "\r\n.\r\n");
        fgets($smtpconn, 515);
        
        fputs($smtpconn, "QUIT\r\n");
        fclose($smtpconn);
        
        return ['success' => true];
    } catch (Exception $e) {
        return ['success' => false, 'error' => $e->getMessage()];
    }
}

// ============================================================
// API ROUTES
// ============================================================

$db = initDB();

switch ($action) {
    
    // --------------------------------------------------------
    // VALIDATE KEY - Called from iOS tweak
    // GET /api/?action=validate&key=XXXX-XXXX-XXXX-XXXX&udid=DEVICE_UDID
    // --------------------------------------------------------
    case 'validate':
        $licenseKey = strtoupper(str_replace('-', '', $_REQUEST['key'] ?? ''));
        $deviceUDID = $_REQUEST['udid'] ?? '';
        
        if (strlen($licenseKey) !== 16) {
            echo json_encode(['success' => false, 'error' => 'Invalid key format']);
            exit;
        }
        
        // Check database
        $stmt = $db->prepare("SELECT * FROM keys WHERE license_key = ?");
        $stmt->execute([$licenseKey]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($row) {
            // Key exists in database
            if ($row['status'] === 'revoked') {
                echo json_encode(['success' => false, 'error' => 'Key has been revoked']);
                exit;
            }
            
            if ($row['status'] === 'used' && $row['device_udid'] !== $deviceUDID) {
                echo json_encode(['success' => false, 'error' => 'Key already used on another device']);
                exit;
            }
            
            // Check expiry
            if ($row['expires_at']) {
                $expiry = strtotime($row['expires_at']);
                if ($expiry < time()) {
                    $db->prepare("UPDATE keys SET status='expired' WHERE id=?")->execute([$row['id']]);
                    echo json_encode(['success' => false, 'error' => 'Key has expired']);
                    exit;
                }
            }
            
            // Update activation
            if ($row['status'] === 'active') {
                $stmt = $db->prepare("UPDATE keys SET status='used', device_udid=?, activated_at=CURRENT_TIMESTAMP WHERE id=?");
                $stmt->execute([$deviceUDID, $row['id']]);
            }
            
            // Log
            $db->prepare("INSERT INTO logs (license_key, action, device_udid, ip_address) VALUES (?, 'validate', ?, ?)")
               ->execute([$licenseKey, $deviceUDID, $_SERVER['REMOTE_ADDR'] ?? '']);
            
            echo json_encode([
                'success' => true,
                'message' => 'Key is valid',
                'device' => $deviceUDID
            ]);
        } else {
            // Key not in DB - use local validation (fallback)
            $expectedKey = generateLicenseKey($deviceUDID);
            $cleanExpected = str_replace('-', '', $expectedKey);
            
            if ($licenseKey === $cleanExpected) {
                echo json_encode(['success' => true, 'message' => 'Key valid (local mode)', 'device' => $deviceUDID]);
            } else {
                echo json_encode(['success' => false, 'error' => 'Invalid key for this device']);
            }
        }
        break;
    
    // --------------------------------------------------------
    // GENERATE KEY - Admin only
    // GET /api/?action=generate&admin_key=XXX&udid=DEVICE_UDID&expiry=2026-12-31&email=user@email.com
    // --------------------------------------------------------
    case 'generate':
        validateAdmin();
        
        $deviceUDID = $_REQUEST['udid'] ?? '';
        $expiryDate = $_REQUEST['expiry'] ?? null;
        $email = $_REQUEST['email'] ?? '';
        $notes = $_REQUEST['notes'] ?? '';
        
        if (empty($deviceUDID)) {
            echo json_encode(['success' => false, 'error' => 'Device UDID required']);
            exit;
        }
        
        // Generate key
        $licenseKey = generateLicenseKey($deviceUDID);
        $cleanKey = str_replace('-', '', $licenseKey);
        
        // Check if key already exists
        $stmt = $db->prepare("SELECT id FROM keys WHERE license_key = ?");
        $stmt->execute([$cleanKey]);
        
        if ($stmt->fetch()) {
            // Very unlikely, but handle collision by appending a counter
            $licenseKey = generateLicenseKey($deviceUDID . time());
            $cleanKey = str_replace('-', '', $licenseKey);
        }
        
        // Insert into database
        $stmt = $db->prepare("INSERT INTO keys (license_key, device_udid, status, expires_at, email, notes) VALUES (?, ?, 'active', ?, ?, ?)");
        $stmt->execute([$cleanKey, $deviceUDID, $expiryDate, $email, $notes]);
        
        // Log
        $db->prepare("INSERT INTO logs (license_key, action, ip_address) VALUES (?, 'generated', ?)")
           ->execute([$cleanKey, $_SERVER['REMOTE_ADDR'] ?? '']);
        
        echo json_encode([
            'success' => true,
            'key' => $licenseKey,
            'key_raw' => $cleanKey,
            'device_udid' => $deviceUDID,
            'expires_at' => $expiryDate ?? 'never',
            'email' => $email
        ]);
        break;
    
    // --------------------------------------------------------
    // REVOKE KEY - Admin only
    // GET /api/?action=revoke&admin_key=XXX&key=XXXX-XXXX-XXXX-XXXX
    // --------------------------------------------------------
    case 'revoke':
        validateAdmin();
        
        $licenseKey = strtoupper(str_replace('-', '', $_REQUEST['key'] ?? ''));
        
        if (strlen($licenseKey) !== 16) {
            echo json_encode(['success' => false, 'error' => 'Invalid key format']);
            exit;
        }
        
        $stmt = $db->prepare("UPDATE keys SET status='revoked' WHERE license_key=?");
        $stmt->execute([$licenseKey]);
        
        if ($stmt->rowCount() > 0) {
            $db->prepare("INSERT INTO logs (license_key, action, ip_address) VALUES (?, 'revoked', ?)")
               ->execute([$licenseKey, $_SERVER['REMOTE_ADDR'] ?? '']);
            echo json_encode(['success' => true, 'message' => 'Key revoked']);
        } else {
            echo json_encode(['success' => false, 'error' => 'Key not found in database']);
        }
        break;
    
    // --------------------------------------------------------
    // LIST KEYS - Admin only
    // GET /api/?action=list&admin_key=XXX
    // --------------------------------------------------------
    case 'list':
        validateAdmin();
        
        $stmt = $db->query("SELECT * FROM keys ORDER BY id DESC LIMIT 500");
        $keys = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'count' => count($keys),
            'keys' => $keys
        ]);
        break;
    
    // --------------------------------------------------------
    // GET LOGS - Admin only
    // GET /api/?action=logs&admin_key=XXX
    // --------------------------------------------------------
    case 'logs':
        validateAdmin();
        
        $stmt = $db->query("SELECT * FROM logs ORDER BY id DESC LIMIT 200");
        $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'count' => count($logs),
            'logs' => $logs
        ]);
        break;
    
    // --------------------------------------------------------
    // SEND KEY VIA EMAIL - Admin only
    // GET /api/?action=send_email&admin_key=XXX&key=XXXX-XXXX-XXXX-XXXX&email=user@example.com
    // --------------------------------------------------------
    case 'send_email':
        validateAdmin();
        
        $licenseKey = str_replace('-', '', $_REQUEST['key'] ?? '');
        $toEmail = $_REQUEST['email'] ?? '';
        
        if (empty($licenseKey) || empty($toEmail)) {
            echo json_encode(['success' => false, 'error' => 'Key and email required']);
            exit;
        }
        
        // Format key with dashes for display
        $formattedKey = strtoupper(substr($licenseKey, 0, 4)) . '-' .
                        strtoupper(substr($licenseKey, 4, 4)) . '-' .
                        strtoupper(substr($licenseKey, 8, 4)) . '-' .
                        strtoupper(substr($licenseKey, 12, 4));
        
        $subject = "Your FFZ License Key";
        $body = "Thank you for purchasing FFZ Mod Menu!\n\n"
              . "Your License Key: " . $formattedKey . "\n\n"
              . "Instructions:\n"
              . "1. Install the tweak on your jailbroken iPhone\n"
              . "2. Open Free Fire\n"
              . "3. When the key prompt appears, enter this key\n"
              . "4. The key is device-specific - use only on your device\n\n"
              . "Thank you!\n"
              . "FFZ Team";
        
        $result = sendEmail($toEmail, $subject, $body);
        
        echo json_encode($result);
        break;
    
    // --------------------------------------------------------
    // CHECK SERVER STATUS
    // GET /api/?action=ping
    // --------------------------------------------------------
    case 'ping':
        echo json_encode([
            'success' => true,
            'message' => 'KeyAuth Server is running',
            'version' => '1.0',
            'php_version' => phpversion()
        ]);
        break;
    
    // --------------------------------------------------------
    // DEFAULT - Show usage info
    // --------------------------------------------------------
    default:
        echo json_encode([
            'success' => true,
            'message' => 'FFZ KeyAuth API Server',
            'endpoints' => [
                'validate' => '?action=validate&key=KEY&udid=UDID',
                'generate' => '?action=generate&admin_key=ADMIN_KEY&udid=UDID',
                'revoke'   => '?action=revoke&admin_key=ADMIN_KEY&key=KEY',
                'list'     => '?action=list&admin_key=ADMIN_KEY',
                'logs'     => '?action=logs&admin_key=ADMIN_KEY',
                'send_email' => '?action=send_email&admin_key=ADMIN_KEY&key=KEY&email=EMAIL',
                'ping'     => '?action=ping'
            ],
            'version' => '1.0'
        ]);
        break;
}
?>
