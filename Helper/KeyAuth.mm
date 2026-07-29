//
//  KeyAuth.mm
//  iOS KeyAuth System - Supports Custom API + KeyAuth.cc
//  =====================================================
//  ★ HOW TO USE ★
//  1. Set BACKEND_MODE to choose backend:
//     - @"custom"    → Uses your own PHP API server
//     - @"keyauthcc" → Uses KeyAuth.cc API
//     - @"localonly" → Local HMAC only (no API)
//  2. Configure the appropriate settings below
//  3. Keys are device-specific (HWID/UDID locked)
//  4. Falls back to local HMAC if API is unreachable
//  =====================================================

#import "KeyAuth.h"
#import <CommonCrypto/CommonHMAC.h>

// ============================================================
// ★★★ BACKEND SELECTION ★★★
// ============================================================
// Choose one:
//   @"custom"     - Your own PHP API (KeyAuthServer/api/)
//   @"keyauthcc"  - https://keyauth.cc service
//   @"localonly"  - No API, local HMAC-SHA256 only
// ============================================================
#define BACKEND_MODE @"keyauthcc"  // ← CHANGE THIS as needed

// ============================================================
// ★★★ LOCAL HMAC SETTINGS ★★★
// ============================================================
// Used for local fallback validation (works with all backends)
#define KEYAUTH_SECRET @"ZexisSecretKey_FFZ_2024"

// ============================================================
// ★★★ OPTION A: Custom PHP API Settings ★★★
// ============================================================
// Only used when BACKEND_MODE is @"custom"
#define API_SERVER_URL @"https://yourdomain.com/api/index.php"

// ============================================================
// ★★★ OPTION B: KeyAuth.cc Settings ★★★
// ============================================================
// Only used when BACKEND_MODE is @"keyauthcc"
// Get these from https://keyauth.cc/dashboard
#define KEYAUTHCC_SELLER_KEY @"gXzvElWWWM"
#define KEYAUTHCC_APP_NAME   @"PRIME PANEL"

// ============================================================
// API Timeout (seconds)
// ============================================================
#define API_TIMEOUT 5.0

// ============================================================

@interface KeyAuth()
@property (nonatomic, assign) BOOL authenticated;
@property (nonatomic, strong) NSString *sessionId;
@end

@implementation KeyAuth

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static KeyAuth *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KeyAuth alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionId = @"";
        NSString *savedKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"FFZ_AuthKey"];
        if (savedKey.length > 0) {
            self.authenticated = [self validateKey:savedKey];
        }
    }
    return self;
}

#pragma mark - Properties

- (BOOL)isAuthenticated {
    return self.authenticated;
}

#pragma mark - HMAC-SHA256 Helper

+ (NSString *)hmacSHA256WithKey:(NSString *)key data:(NSString *)data {
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, (CC_LONG)strlen(cKey), cData, (CC_LONG)strlen(cData), cHMAC);
    
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02X", cHMAC[i]];
    }
    return hash;
}

#pragma mark - Device ID (HWID)

- (NSString *)getDeviceUDID {
    // Same as HWID - unique per device
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return udid ?: @"UNKNOWN_DEVICE";
}

#pragma mark - Synchronous HTTP POST Helper

- (NSDictionary *)syncHTTPPost:(NSString *)urlString body:(NSString *)body {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSDictionary *resultDict = nil;
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCache
                                                       timeoutInterval:API_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)((API_TIMEOUT + 1) * NSEC_PER_SEC)));
    return resultDict;
}

- (NSDictionary *)syncHTTPGet:(NSString *)urlString {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSDictionary *resultDict = nil;
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) return nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCache
                                                       timeoutInterval:API_TIMEOUT];
    [request setHTTPMethod:@"GET"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)((API_TIMEOUT + 1) * NSEC_PER_SEC)));
    return resultDict;
}

#pragma mark - Local HMAC Validation (Fallback)

- (BOOL)validateLocalKey:(NSString *)cleanKey {
    NSString *deviceUDID = [self getDeviceUDID];
    NSString *expectedHash = [KeyAuth hmacSHA256WithKey:KEYAUTH_SECRET data:deviceUDID];
    NSString *expectedKey = [[expectedHash substringToIndex:16] uppercaseString];
    return [cleanKey isEqualToString:expectedKey];
}

#pragma mark - KeyAuth.cc API

- (BOOL)validateWithKeyauthCC:(NSString *)key deviceUDID:(NSString *)udid {
    // URL-encode app name (handles spaces like "PRIME PANEL" → "PRIME%20PANEL")
    NSString *encodedApp = [KEYAUTHCC_APP_NAME stringByAddingPercentEncodingWithAllowedCharacters:
                             [NSCharacterSet URLPathAllowedCharacterSet]];
    NSString *apiBase = [NSString stringWithFormat:@"https://keyauth.cc/api/v1/%@/%@/",
                         KEYAUTHCC_SELLER_KEY, encodedApp];
    
    // Step 1: INIT - Initialize session
    NSDictionary *initResult = [self syncHTTPPost:apiBase body:@"type=init&ver=1.0"];
    if (![initResult[@"success"] boolValue]) {
        return NO; // Invalid seller key or network error
    }
    
    // Step 2: LOGIN - Validate the key with HWID
    NSString *loginBody = [NSString stringWithFormat:@"type=login&key=%@&hwid=%@&sessionid=&format=json",
                           [key uppercaseString], [udid lowercaseString]];
    
    NSDictionary *result = [self syncHTTPPost:apiBase body:loginBody];
    if (!result) return NO;
    
    BOOL success = [result[@"success"] boolValue];
    if (success) {
        self.sessionId = result[@"sessionid"] ?: @"";
    }
    
    return success;
}

#pragma mark - Custom PHP API Validation

- (BOOL)validateWithCustomAPI:(NSString *)key deviceUDID:(NSString *)udid {
    if (API_SERVER_URL.length == 0) return NO;
    
    NSString *urlString = [NSString stringWithFormat:@"%@?action=validate&key=%@&udid=%@",
                           API_SERVER_URL, key, udid];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:
                 [NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSDictionary *result = [self syncHTTPGet:urlString];
    if (!result) return NO;
    
    return [result[@"success"] boolValue];
}

#pragma mark - Main Key Validation Flow

- (BOOL)validateKey:(NSString *)key {
    // Clean the key (remove separators)
    NSString *cleanKey = [[key stringByReplacingOccurrencesOfString:@"-" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // =====================================================
    // KeyAuth.cc: Keys can be any format - let API decide
    // Custom/Local: Keys must be 16 hex chars
    // =====================================================
    
    if (![BACKEND_MODE isEqualToString:@"keyauthcc"]) {
        // For custom API & local mode: strict 16-hex validation
        cleanKey = [cleanKey uppercaseString];
        if (cleanKey.length != 16) return NO;
        NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
        if ([cleanKey rangeOfCharacterFromSet:[hexSet invertedSet]].location != NSNotFound) {
            return NO;
        }
    }
    
    NSString *deviceUDID = [self getDeviceUDID];
    BOOL apiResult = NO;
    
    // Try API validation based on backend mode
    if ([BACKEND_MODE isEqualToString:@"keyauthcc"]) {
        apiResult = [self validateWithKeyauthCC:cleanKey deviceUDID:deviceUDID];
    } else if ([BACKEND_MODE isEqualToString:@"custom"]) {
        apiResult = [self validateWithCustomAPI:cleanKey deviceUDID:deviceUDID];
    }
    
    if (apiResult) {
        return YES;
    }
    
    // Fallback to local validation (only for 16-char hex keys)
    if (cleanKey.length == 16) {
        cleanKey = [cleanKey uppercaseString];
        NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
        if ([cleanKey rangeOfCharacterFromSet:[hexSet invertedSet]].location == NSNotFound) {
            return [self validateLocalKey:cleanKey];
        }
    }
    
    return NO;
}

#pragma mark - Key Activation

- (BOOL)activateWithKey:(NSString *)key {
    if ([self validateKey:key]) {
        self.authenticated = YES;
        [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"FFZ_AuthKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

#pragma mark - Login UI

- (void)showLoginWithCompletion:(void (^)(BOOL success))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🔐 Key Activation Required"
                                                                       message:@"Enter your license key below to unlock the mod menu."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"XXXX-XXXX-XXXX-XXXX";
            textField.keyboardType = UIKeyboardTypeASCIICapable;
            textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.textAlignment = NSTextAlignmentCenter;
            textField.returnKeyType = UIReturnKeyDone;
        }];
        
        UIAlertAction *activateAction = [UIAlertAction actionWithTitle:@"Activate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *enteredKey = alert.textFields.firstObject.text ?: @"";
            
            if ([self activateWithKey:enteredKey]) {
                UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"✅ Activated"
                                                                                      message:@"License key is valid! The mod is now unlocked."
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                [successAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    if (completion) completion(YES);
                }]];
                
                UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                [rootVC presentViewController:successAlert animated:YES completion:nil];
            } else {
                UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"❌ Invalid Key"
                                                                                   message:@"The key you entered is not valid for this device. Please check and try again."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                [failAlert addAction:[UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self showLoginWithCompletion:completion];
                }]];
                [failAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    if (completion) completion(NO);
                }]];
                
                UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                [rootVC presentViewController:failAlert animated:YES completion:nil];
            }
        }];
        
        [alert addAction:activateAction];
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (!rootVC) {
            rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        }
        if (rootVC) {
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    });
}

#pragma mark - Reset

- (void)resetAuth {
    self.authenticated = NO;
    self.sessionId = @"";
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FFZ_AuthKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Key Generator (Admin Use)

+ (NSString *)generateKeyForDevice:(NSString *)deviceUDID {
    if (deviceUDID.length == 0) return nil;
    
    NSString *hash = [self hmacSHA256WithKey:KEYAUTH_SECRET data:deviceUDID];
    NSString *keyPart = [[hash substringToIndex:16] uppercaseString];
    
    return [NSString stringWithFormat:@"%@-%@-%@-%@",
            [keyPart substringWithRange:NSMakeRange(0, 4)],
            [keyPart substringWithRange:NSMakeRange(4, 4)],
            [keyPart substringWithRange:NSMakeRange(8, 4)],
            [keyPart substringWithRange:NSMakeRange(12, 4)]];
}

@end
