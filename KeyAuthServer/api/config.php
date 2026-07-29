<?php
// ============================================================
// KeyAuth Server Configuration
// ============================================================
// Change these settings before uploading to your server!
// ============================================================

// ★★★ ADMIN SECRET KEY - Change this! ★★★
// This is used to authenticate admin API calls (not user keys)
define('ADMIN_SECRET', 'ChangeThisToYourSecretKey2024');

// ★★★ MASTER SECRET for key generation ★★★
// Must match KEYAUTH_SECRET in the iOS tweak's KeyAuth.mm
define('MASTER_SECRET', 'ZexisSecretKey_FFZ_2024');

// Database file path (SQLite)
define('DB_PATH', __DIR__ . '/keyauth.db');

// ============================================================
// GMAIL / SMTP Settings (for sending keys via email)
// ============================================================
define('SMTP_ENABLED', false);       // Set to true to enable email
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'your-email@gmail.com');     // Your Gmail
define('SMTP_PASSWORD', 'your-app-password');        // Gmail App Password
define('SMTP_FROM_EMAIL', 'your-email@gmail.com');
define('SMTP_FROM_NAME', 'FFZ KeyAuth');

// ============================================================
// API Settings
// ============================================================
define('API_ACCESS_CONTROL', '*');   // Allow all origins (*)
?>
