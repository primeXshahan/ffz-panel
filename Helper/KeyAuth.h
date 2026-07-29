//
//  KeyAuth.h
//  Local Key Authentication System
//  No external server required!
//
//  ★ USAGE FOR ADMIN ★
//  1. Change KEYAUTH_SECRET in KeyAuth.mm to your own secret
//  2. Get user's device UDID
//  3. Generate key: [KeyAuth generateKeyForDevice:@"user-udid-here"]
//  4. Send generated key to user
//  5. User enters key in the login popup → menu unlocks
//
//  ★ CHANGE SECRET TO INVALIDATE ALL KEYS ★
//  Just change KEYAUTH_SECRET → all old keys become invalid!
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyAuth : NSObject

/// Singleton instance
+ (instancetype)sharedInstance;

/// Check if device is authenticated (has valid saved key)
@property (nonatomic, readonly) BOOL isAuthenticated;

/// Try to activate with a license key
/// @param key The license key to validate
/// @return YES if key is valid for this device
- (BOOL)activateWithKey:(NSString *)key;

/// Show the login popup alert
/// @param completion Called when login flow completes
- (void)showLoginWithCompletion:(void (^)(BOOL success))completion;

/// Get this device's unique identifier (for key generation)
- (NSString *)getDeviceUDID;

/// ★ ADMIN: Generate a license key for a specific device
/// @param deviceUDID The device UDID to generate key for
/// @return Formatted license key string (XXXX-XXXX-XXXX-XXXX)
+ (NSString *)generateKeyForDevice:(NSString *)deviceUDID;

/// Reset authentication (clear saved key)
- (void)resetAuth;

@end

NS_ASSUME_NONNULL_END
