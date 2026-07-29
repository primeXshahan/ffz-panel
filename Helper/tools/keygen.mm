//
//  keygen.mm - Standalone Key Generator Tool
//  =========================================
//  Run this on your iPhone via NewTerm to generate license keys!
//
//  ★ HOW TO USE ★
//  cd Helper/tools
//  clang++ -framework Foundation -framework UIKit keygen.mm ../KeyAuth.mm -o keygen
//  ./keygen <device_udid>
//
//  ★ GET USER'S UDID ★
//  ./keygen --list
//
//  ★ CHANGE SECRET ★
//  Edit KEYAUTH_SECRET in ../KeyAuth.mm before compiling!
//

#import <Foundation/Foundation.h>
#import "../KeyAuth.h"

void printUsage() {
    printf("\n");
    printf("╔══════════════════════════════════════════╗\n");
    printf("║      FFZ Key Generator v1.0              ║\n");
    printf("╚══════════════════════════════════════════╝\n");
    printf("\n");
    printf("USAGE:\n");
    printf("  ./keygen <device_udid>     Generate a key for a device\n");
    printf("  ./keygen --list           Show this device's UDID\n");
    printf("  ./keygen --help           Show this help\n");
    printf("\n");
    printf("EXAMPLE:\n");
    printf("  ./keygen E621E1F8-C36C-495A-93FC-0C247A3E6E5F\n");
    printf("\n");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            printUsage();
            return 1;
        }
        
        NSString *arg = [NSString stringWithUTF8String:argv[1]];
        
        if ([arg isEqualToString:@"--help"] || [arg isEqualToString:@"-h"]) {
            printUsage();
            return 0;
        }
        else if ([arg isEqualToString:@"--list"] || [arg isEqualToString:@"-l"]) {
            NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            printf("\n");
            printf("✅ THIS DEVICE UDID:\n");
            printf("   %s\n", [udid UTF8String]);
            printf("\n");
            printf("To generate a key for this device:\n");
            printf("   ./keygen %s\n", [udid UTF8String]);
            printf("\n");
        }
        else {
            // Generate key for the provided UDID
            NSString *deviceUDID = arg;
            NSString *key = [KeyAuth generateKeyForDevice:deviceUDID];
            
            if (key) {
                printf("\n");
                printf("╔══════════════════════════════════════════╗\n");
                printf("║           LICENSE KEY GENERATED          ║\n");
                printf("╚══════════════════════════════════════════╝\n");
                printf("\n");
                printf("  Device UDID: %s\n", [deviceUDID UTF8String]);
                printf("  ─────────────────────────────────────────\n");
                printf("  🔑 KEY:  %s\n", [key UTF8String]);
                printf("  ─────────────────────────────────────────\n");
                printf("\n");
                printf("  Send this key to the user.\n");
                printf("  Valid ONLY for the above device!\n");
                printf("\n");
            } else {
                printf("❌ Error: Invalid device UDID\n");
                return 1;
            }
        }
    }
    return 0;
}
