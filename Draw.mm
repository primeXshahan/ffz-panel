#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include <iostream>
#include <UIKit/UIKit.h>
#include <vector>
#import "pthread.h"
#include <array>
#import "menuUIKIT/drawview.h"
#import "menuUIKIT/touchView.h"
#import "Themes/ThemeManager.h"
#import "Themes/UIComponents.h"
#import "menuUIKIT/Vars.h"
// #import "API/LicenseManager.h"  // Optional - use runtime checks instead
#import <unistd.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <stdlib.h>
#import <os/log.h>
#include <cmath>
#include <deque>
#include <fstream>
#include <algorithm>
#import "Esp/SecureMap.h"
#import "JRMemory.framework/JRHelper.h"
#import "API/APIClient.h"
#include <string>
#include "JRMemory.framework/Headers/MemScan.h"
#include <map>
#include <vector>
#import <mach-o/dyld.h>
#import <mach-o/dyld_images.h>
#import <dlfcn.h>
#import <arpa/inet.h>
#import <sys/socket.h>
#include "Helper/Vector3.h"  
#import "Helper/SecurityCheck.h"
#import <substrate.h> 
#include "hook/hook.h"
#include <sstream>
#include <cstring>
#include <cstdlib>
#import <sys/sysctl.h>
#include <cstdio>
#include <cstdint>

#include <cinttypes>
#include <cerrno>
#include <cctype>
#import <CommonCrypto/CommonCrypto.h>
#import "Esp/CaptainHook.h"
#include "oxorany/oxorany_include.h"
#import "Helper/Mem.h"
#include "font.h"
#import "Helper/Vector3.h"
#import "Helper/Vector2.h"
#import "Helper/Quaternion.h"
#import "Helper/Monostring.h"
#include "Helper/font.h"
#include "Helper/data.h"
#include "Helper/Obfuscate.h"
#import "menuUIKIT/drawfunc.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <unistd.h>

#include <string.h>
#import <objc/message.h>
#import <objc/runtime.h>

#define patch_NULL(a, b) \
    vm(ENCRYPTOFFSET(a), strtoul(ENCRYPTHEX(b), nullptr, 0))
#define patch(a, b) \
    vm_unity(ENCRYPTOFFSET(a), strtoul(ENCRYPTHEX(b), nullptr, 0))

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale


bool Guest(void* _this) { 
    return true; 
}

bool SetHighFPS(void* _this) { 
    return true; 
}
static const NSInteger kFeatureButtonBaseTag = 88800;
static const NSInteger kGhostButtonTag = 88801;
static const NSInteger kTeleVIPButtonTag = 88802;
static const NSInteger kUndergroundButtonTag = 88803;
static const NSInteger kAITelekillButtonTag = 88804;
static const NSInteger kNinjaRunButtonTag = 88805;
static const NSInteger kFlyAlturaButtonTag = 88806;
static const NSInteger kFlyNormalButtonTag = 88807;
static const NSInteger kSavePosButtonTag = 88808;
static const NSInteger kClearAntiuButtonTag = 88809;
static const NSInteger kMagnetKillButtonTag = 88810;

// Extern declarations for color variables from func.h
extern int ESPLineColor;
extern int ESPBoxColor;
extern int ESPSkeletonColor;
extern int ESPNameColor;
extern int AimbotFOVColor;
extern float AimbotFOVThickness;
extern int MenuColorTheme;
bool fmedkit = false;

bool StopGarenaLogs = false;
bool FastSwitch = false;

// Save Pos feature variables
bool testGhost = false;
bool func_ghost = false;

typedef NS_ENUM(NSInteger, MenuTab) {
    MenuTabAimbot = 0, 
    MenuTabESP, 
    MenuTabMSL, 
    MenuTabWeapons,
    MenuTabProfile
};
@interface ModMenuViewController () <UIGestureRecognizerDelegate>
- (void)saveSettingsToFile;
- (void)loadSettingsFromFile;
- (void)saveUIState;
- (void)loadUIState;
- (NSString *)settingsFilePath;
@property (nonatomic, strong) UIScrollView *sidebarScrollView;
@property (nonatomic, strong) UIView *sidebarView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, assign) MenuTab currentTab;
@property (nonatomic, strong) NSMutableArray *tabButtons;
@property (nonatomic, strong) NSMutableDictionary *checkboxStates;
@property (nonatomic, strong) NSTimer *fpsTimer;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, assign) CGFloat currentFPS;
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *headerButton;
@property (nonatomic, strong) UIView *tabSelectorPopup;
@property (nonatomic, strong) UIVisualEffectView *headerBlurView;
@property (nonatomic, strong) UIColor *currentThemeColor;
@property (nonatomic, assign) BOOL isUpdatingUI;
@property (nonatomic, assign) BOOL isChangingTab;
@property (nonatomic, assign) NSInteger currentLanguage; // 0 = English, 1 = Portuguese


@end

@implementation ModMenuViewController {
    UIView *floatingPanel;
    UIButton *themeToggle;
    UIButton *closeButton;
    CGFloat panelWidth;
}

// Helper to safely get LicenseManager (optional)
- (id)getLicenseManager {
    Class licenseClass = NSClassFromString(@"LicenseManager");
    if (licenseClass && [licenseClass respondsToSelector:@selector(shared)]) {
        return [licenseClass performSelector:@selector(shared)];
    }
    return nil;
}
    CGFloat panelHeight;
    BOOL isDarkMode;
    NSMutableDictionary *allCheckboxes;



// Global ModMenuViewController instance for theme access from ESP drawing
static ModMenuViewController *g_ModMenuInstance = nil;

// C function to set the global instance (called from viewDidLoad)
void SetModMenuInstance(ModMenuViewController *instance) {
    g_ModMenuInstance = instance;
}

// C functions to get theme colors for ESP drawing
UIColor* GetThemeAccentColor(void) {
    if (g_ModMenuInstance && [g_ModMenuInstance respondsToSelector:@selector(accentColor)]) {
        return [g_ModMenuInstance accentColor];
    }
    // Fallback to red theme
    return [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
}

UIColor* GetThemeTextColor(void) {
    if (g_ModMenuInstance && [g_ModMenuInstance respondsToSelector:@selector(textColor)]) {
        return [g_ModMenuInstance textColor];
    }
    // Fallback to white
    return [UIColor whiteColor];
}

UIColor* GetThemeGlowColor(void) {
    if (g_ModMenuInstance && [g_ModMenuInstance respondsToSelector:@selector(glowColor)]) {
        return [g_ModMenuInstance glowColor];
    }
    // Fallback
    return [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.7];
}

#pragma mark - Global Sizing Constants

static const CGFloat kSidebarWidth = 70;
static const CGFloat kTabIconSize = 48;
static const CGFloat kTabIconImageSize = 28;
static const CGFloat kTabSpacing = 8;
static const CGFloat kPillHeight = 50;
static const CGFloat kPillSpacing = 7;
static const CGFloat kContentPadding = 10;
static const CGFloat kContentTopInset = 5;
static const CGFloat kContentBottomInset = 10;
static const CGFloat kSeparatorPadding = 25;





void secureCrash() {
    volatile char *ptr = (char *)0x1;
    *ptr = 0xFF;
}


void switchfast (void* _this) {

    return;
}


float fastmedkit(void* _this) {
    return 9.0;
}








#pragma mark - Colors

- (UIColor *)backgroundColor {
    // Use selected menu color theme
    switch (MenuColorTheme) {
        case 0: // Red
            if (isDarkMode) {
                return [UIColor colorWithRed:0.05 green:0.01 blue:0.01 alpha:1.0];
            } else {
                return [UIColor colorWithRed:0.99 green:0.95 blue:0.95 alpha:1.0];
            }
        case 1: // Blue
            if (isDarkMode) {
                return [UIColor colorWithRed:0.01 green:0.01 blue:0.05 alpha:1.0];
            } else {
                return [UIColor colorWithRed:0.95 green:0.95 blue:0.99 alpha:1.0];
            }
        case 2: // Green
            if (isDarkMode) {
                return [UIColor colorWithRed:0.01 green:0.05 blue:0.01 alpha:1.0];
            } else {
                return [UIColor colorWithRed:0.95 green:0.99 blue:0.95 alpha:1.0];
            }
        case 3: // Pink
            if (isDarkMode) {
                return [UIColor colorWithRed:0.05 green:0.01 blue:0.03 alpha:1.0];
            } else {
                return [UIColor colorWithRed:0.99 green:0.95 blue:0.97 alpha:1.0];
            }
        default: // Red (fallback)
            if (isDarkMode) {
                return [UIColor colorWithRed:0.05 green:0.01 blue:0.01 alpha:1.0];
            } else {
                return [UIColor colorWithRed:0.99 green:0.95 blue:0.95 alpha:1.0];
            }
    }
}

- (UIColor *)textColor { 
    return isDarkMode ? [UIColor whiteColor] : [UIColor blackColor]; 
}

- (UIColor *)secondaryTextColor { 
    return isDarkMode ? 
        [UIColor colorWithWhite:0.5 alpha:1.0] : 
        [UIColor colorWithWhite:0.5 alpha:1.0]; 
}

- (UIColor *)accentColor {
    // Return color based on selected theme
    switch (MenuColorTheme) {
        case 0: // Red
            return [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
        case 1: // Blue
            return [UIColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:1.0];
        case 2: // Green
            return [UIColor colorWithRed:0.2 green:1.0 blue:0.2 alpha:1.0];
        case 3: // Pink
            return [UIColor colorWithRed:1.0 green:0.4 blue:0.8 alpha:1.0];
        default: // Red (fallback)
            return [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
    }
}

- (UIColor *)pillColor {
    // Use selected menu color theme
    switch (MenuColorTheme) {
        case 0: // Red
            if (isDarkMode) {
                return [UIColor colorWithRed:0.15 green:0.03 blue:0.03 alpha:1.0];
            } else {
                return [UIColor colorWithWhite:0.96 alpha:1.0];
            }
        case 1: // Blue
            if (isDarkMode) {
                return [UIColor colorWithRed:0.03 green:0.03 blue:0.15 alpha:1.0];
            } else {
                return [UIColor colorWithWhite:0.96 alpha:1.0];
            }
        case 2: // Green
            if (isDarkMode) {
                return [UIColor colorWithRed:0.03 green:0.15 blue:0.03 alpha:1.0];
            } else {
                return [UIColor colorWithWhite:0.96 alpha:1.0];
            }
        case 3: // Pink
            if (isDarkMode) {
                return [UIColor colorWithRed:0.15 green:0.03 blue:0.08 alpha:1.0];
            } else {
                return [UIColor colorWithWhite:0.96 alpha:1.0];
            }
        default: // Red (fallback)
            if (isDarkMode) {
                return [UIColor colorWithRed:0.15 green:0.03 blue:0.03 alpha:1.0];
            } else {
                return [UIColor colorWithWhite:0.96 alpha:1.0];
            }
    }
}


- (UIColor *)checkboxOffColor { 
    return isDarkMode ? 
        [UIColor colorWithWhite:0.25 alpha:1.0] : 
        [UIColor colorWithWhite:0.7 alpha:1.0]; 
}

- (UIColor *)glowColor {
    return [[self accentColor] colorWithAlphaComponent:0.6];
}

#pragma mark - UI State Persistence (Tab & Theme)

- (void)saveUIState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.currentTab forKey:@"ModMenuCurrentTab"];
    [defaults setBool:isDarkMode forKey:@"ModMenuDarkMode"];
    [defaults synchronize];
}

- (void)loadUIState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"ModMenuCurrentTab"]) {
        self.currentTab = (MenuTab)[defaults integerForKey:@"ModMenuCurrentTab"];
    } else {
        self.currentTab = MenuTabAimbot;
    }
    
    // Load language preference
    if ([defaults objectForKey:@"ModMenuLanguage"]) {
        self.currentLanguage = [defaults integerForKey:@"ModMenuLanguage"];
    } else {
        self.currentLanguage = 0; // Default to English
    }
    
    if ([defaults objectForKey:@"ModMenuDarkMode"]) {
        isDarkMode = [defaults boolForKey:@"ModMenuDarkMode"];
    } else {
        isDarkMode = YES;
    }
    
}

#pragma mark - Settings File Management

- (NSString *)settingsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory 
        stringByAppendingPathComponent:@"menu_settings.txt"];
}

- (void)saveSettingsToFile {
    NSMutableString *settingsString = [NSMutableString string];
    
    // Save ESP settings
    [settingsString appendFormat:@"Enable=%d\n", Vars.Enable ? 1 : 0];
    [settingsString appendFormat:@"Box=%d\n", Vars.Box ? 1 : 0];
    [settingsString appendFormat:@"Lines=%d\n", Vars.lines ? 1 : 0];
    [settingsString appendFormat:@"Skeleton=%d\n", Vars.Skeleton ? 1 : 0];
    [settingsString appendFormat:@"Distance=%d\n", Vars.Distance ? 1 : 0];
    [settingsString appendFormat:@"Name=%d\n", Vars.Name ? 1 : 0];
    [settingsString appendFormat:@"EnemyCount=%d\n", Vars.enemycount ? 1 : 0];
    [settingsString appendFormat:@"Glow=%d\n", Vars.Glow ? 1 : 0];
    [settingsString appendFormat:@"TargetPriority=%d\n", Vars.TargetPriority];
    // Save Aimbot settings
    [settingsString appendFormat:@"Aimbot=%d\n", Vars.Aimbot ? 1 : 0];
    [settingsString appendFormat:@"Aimsilent=%d\n", Vars.Aimsilent69 ? 1 : 0];
     [settingsString appendFormat:@"Show Extra Animation=%d\n", Vars.ShowEn ? 1 : 0];

    [settingsString appendFormat:@"RateOfFire=%d\n", Vars.rateoffire ? 1 : 0];
    [settingsString appendFormat:@"AimFov=%.2f\n", Vars.AimFov];
    [settingsString appendFormat:@"AimWhen=%d\n", Vars.AimWhen];
    [settingsString appendFormat:@"Target=%d\n", (int)Vars.Target];
    

    [settingsString appendFormat:@"SpeedHack=%d\n", SpeedHack ? 1 : 0];
    [settingsString appendFormat:@"UpPlayer=%d\n", Vars.UpPlayer ? 1 : 0];
    [settingsString appendFormat:@"Telekill=%d\n", Vars.Telekill ? 1 : 0];
    [settingsString appendFormat:@"UndergroundKill2=%d\n", 
        Vars.UndergroundKill2 ? 1 : 0];
    [settingsString appendFormat:@"NinjaRun=%d\n", Vars.NinjaRun ? 1 : 0];
    [settingsString appendFormat:@"NinjaRunSlow=%d\n", 
        Vars.NinjaRun_Slow ? 1 : 0];
    [settingsString appendFormat:@"NinjaRunFast=%d\n", 
        Vars.NinjaRun_Fast ? 1 : 0];
    [settingsString appendFormat:@"Guest2=%d\n", Guest2 ? 1 : 0];
    
    // Save Misc settings
    [settingsString appendFormat:@"HighFPS=%d\n", HighFPS ? 1 : 0];
    [settingsString appendFormat:@"StreamMode=%d\n", StreamMode ? 1 : 0];
    [settingsString appendFormat:@"FastSwitch=%d\n", FastSwitch ? 1 : 0];
    [settingsString appendFormat:@"IgnoreBot=%d\n", IgnoreBot ? 1 : 0];
    [settingsString appendFormat:@"IgnoreKnocked2=%d\n", IgnoreKnocked2 ? 1 : 0];
[settingsString appendFormat:@"StopLogs=%d\n", StopGarenaLogs ? 1 : 0];
    // Write to file
    NSError *error = nil;
    [settingsString writeToFile:[self settingsFilePath]
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:&error];
}

- (void)loadSettingsFromFile {
    NSString *filePath = [self settingsFilePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    if (error || !content) {
        return;
    }
    
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    
    for (NSString *line in lines) {
        NSArray *parts = [line componentsSeparatedByString:@"="];
        if (parts.count == 2) {
            NSString *key = [parts[0] stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceCharacterSet]];
            NSString *value = [parts[1] stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceCharacterSet]];
            settings[key] = value;
        }
    }
    
    // Apply settings
    if (settings[@"Enable"]) {
        Vars.Enable = [settings[@"Enable"] intValue] == 1;
    }
    if (settings[@"Box"]) {
        Vars.Box = [settings[@"Box"] intValue] == 1;
    }
    if (settings[@"Lines"]) {
        Vars.lines = [settings[@"Lines"] intValue] == 1;
    }
    if (settings[@"Skeleton"]) {
        Vars.Skeleton = [settings[@"Skeleton"] intValue] == 1;
    }
    if (settings[@"Distance"]) {
        Vars.Distance = [settings[@"Distance"] intValue] == 1;
    }
    if (settings[@"Name"]) {
        Vars.Name = [settings[@"Name"] intValue] == 1;
    }

     if (settings[@"EnemyCount"]) {
        Vars.enemycount = [settings[@"EnemyCount"] intValue] == 1;
    }
    if (settings[@"Glow"]) {
        Vars.Glow = [settings[@"Glow"] intValue] == 1;
    }
    if (settings[@"TargetPriority"]) {
        Vars.TargetPriority = [settings[@"TargetPriority"] intValue];
    }
    if (settings[@"Aimbot"]) {
        Vars.Aimbot = [settings[@"Aimbot"] intValue] == 1;
    }
        if (settings[@"Aimsilent"]) {
        Vars.Aimsilent69 = [settings[@"Aimsilent"] intValue] == 1;
    }
        if (settings[@"Show Extra Animation"]) {
        Vars.ShowEn = [settings[@"ShowExtraAnimation"] intValue] == 1;
    }

    if (settings[@"AimKill"]) {
        Vars.playertakedamage2T = [settings[@"AimKill"] intValue] == 1;
    }

    if (settings[@"RateOfFire"]) {
        Vars.rateoffire = [settings[@"RateOfFire"] intValue] == 1;
    }
    if (settings[@"AimFov"]) {
        Vars.AimFov = [settings[@"AimFov"] floatValue];
    }
    if (settings[@"AimWhen"]) {
        Vars.AimWhen = [settings[@"AimWhen"] intValue];
    }
    if (settings[@"Target"]) {
        Vars.Target = (AimTarget)[settings[@"Target"] intValue];
    }
    if (settings[@"ShowButtons"]) {
        Vars.ShowButtons = [settings[@"ShowButtons"] intValue] == 1;
    }
    if (settings[@"SpeedHack"]) {
        SpeedHack = [settings[@"SpeedHack"] intValue] == 1;
    }
    if (settings[@"UpPlayer"]) {
        Vars.UpPlayer = [settings[@"UpPlayer"] intValue] == 1;
    }
    if (settings[@"Telekill"]) {
        Vars.Telekill = [settings[@"Telekill"] intValue] == 1;
    }
    if (settings[@"UndergroundKill2"]) {
        Vars.UndergroundKill2 = [settings[@"UndergroundKill2"] intValue] == 1;
    }
    if (settings[@"NinjaRun"]) {
        Vars.NinjaRun = [settings[@"NinjaRun"] intValue] == 1;
    }
    if (settings[@"NinjaRunSlow"]) {
        Vars.NinjaRun_Slow = [settings[@"NinjaRunSlow"] intValue] == 1;
    }
    if (settings[@"NinjaRunFast"]) {
        Vars.NinjaRun_Fast = [settings[@"NinjaRunFast"] intValue] == 1;
    }
    if (settings[@"Guest2"]) {
        Guest2 = [settings[@"Guest2"] intValue] == 1;
    }
    if (settings[@"HighFPS"]) {
        HighFPS = [settings[@"HighFPS"] intValue] == 1;
    }
    if (settings[@"StreamMode"]) {
        StreamMode = [settings[@"StreamMode"] intValue] == 1;
    }
    if (settings[@"FastSwitch"]) {
    FastSwitch = [settings[@"FastSwitch"] intValue] == 1;
}
if (settings[@"IgnoreBot"]) {
    IgnoreBot = [settings[@"IgnoreBot"] intValue] == 1;
}
if (settings[@"IgnoreKnocked2"]) {
    IgnoreKnocked2 = [settings[@"IgnoreKnocked2"] intValue] == 1;
}
if (settings[@"StopLogs"]) {
    StopGarenaLogs = [settings[@"StopLogs"] intValue] == 1;
}
    
  
}


- (void)undergroundSwitchChanged:(UISwitch *)sender { 
    Vars.invisible = sender.on; 
}

- (void)magnetKillSwitchChanged:(UISwitch *)sender { 
    Vars.MagnetKill = sender.on; 
}


- (void)teleVIPSwitchChanged:(UISwitch *)sender {
    Vars.TeleVIP = sender.on;
    
    // When TeleVIP is turned off, also turn off fly
}

- (void)aiTelekillSwitchChanged:(UISwitch *)sender { 
    Vars.AITelekill = sender.on; 
}



- (void)ninjaRunSwitchChanged:(UISwitch *)sender { 
    Vars.NinjaRun = sender.on; 
}
- (void)ghostSwitchChanged:(UISwitch *)sender {
    Vars.EnableGhost = sender.on;
    static bool gs = false;
    void* ghostMain = (void*)getRealOffset(ENCRYPTOFFSET("0x10330CA14"));
    // FUNC_GHOST removed - ghost functionality disabled
    // if (sender.on && !gs) { Zexis((void*[]){ ghostMain }, (void*[]){ (void*)FUNC_GHOST }, 1); func_ghost = true; gs = true; }
    // else if (!sender.on && gs) { ZexisUnhook(ghostMain); func_ghost = false; gs = false; }
}




typedef struct {
    float x;
    float y;
    float z;
} Vector3Patch;


std::vector<void*> flyAlturaAddresses;
bool flyAlturaPatched = false;

- (void)flyAlturaSwitchChanged:(UISwitch *)sender {
   
    
    if (sender.on) {
            flyalt = true;
}
else {

flyalt = false;
}}
- (void)flyNormalSwitchChanged:(UISwitch *)sender {
    @try {
        if (!sender) return;
        
        BOOL newState = sender.on;
        Vars.fly = newState;
    } @catch (NSException *exception) {
        NSLog(@"Error in flyNormalSwitchChanged: %@", exception);
    }
}

static bool ClearCache = false;



#pragma mark - Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

 
 CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (screenWidth <= 375) {
        panelWidth = 600;
        panelHeight = 320;
    } else if (screenWidth <= 414) {
        panelWidth = 640;
        panelHeight = 350;
    } else {
        panelWidth = 660;
        panelHeight = 370;
    }
    isDarkMode = YES;
    self.currentTab = MenuTabESP;
    
    // Load UI state (tab and theme) - this is safe, no hooks
    [self loadUIState];
    
    // Set fixed theme color (red theme)
    self.currentThemeColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:1.0];
    
    // Set global instance for ESP theme access
    SetModMenuInstance(self);
    
    self.tabButtons = [NSMutableArray array];
    self.checkboxStates = [NSMutableDictionary dictionary];
    allCheckboxes = [NSMutableDictionary dictionary];
    self.frameCount = 0;
    self.currentFPS = 0;
    
    [self setupMainView];
    [self setupFloatingPanel];
    [self setupSidebar];
    [self setupHeaderBar];
    [self setupContentArea];
    
    // Load the saved tab (restored from UI state)
    [self updateSidebarForTab:self.currentTab];
    [self updateHeaderForTab:self.currentTab];
    [self loadTabContent:self.currentTab];
    
    [self setupGestureRecognizers];
    [self setupDisplayLink];
    [self startFPSTimer];
    [self animatePanelEntrance];

    [[NSNotificationCenter defaultCenter] 
        addObserver:self 
           selector:@selector(screenCaptureStatusChanged:) 
               name:UIScreenCapturedDidChangeNotification 
             object:nil];
    
    if (StreamMode) { 
        SetStreamMode(YES); 
        if (floatingPanel) UpdateStreamProtectionForView(floatingPanel); 
        if (self.view) UpdateStreamProtectionForView(self.view); 
    }

}

- (void)startFPSTimer {
    self.fpsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                    repeats:YES 
                                                      block:^(NSTimer *t) {
        self.currentFPS = self.frameCount;
        self.frameCount = 0;
        if (self.fpsLabel) {
            self.fpsLabel.text = [NSString stringWithFormat:@"%.0f", 
                                  self.currentFPS];
        }
        if (self.timeLabel) {
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"HH:mm:ss"];
            self.timeLabel.text = [f stringFromDate:[NSDate date]];
        }
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    // DON'T remove buttons here - they should persist even when menu is closed
    // Buttons are added to window, not view controller, so they stay alive
}
- (void)setupMainView {
    // Don't remove buttons here - they should persist even when menu is closed
    // Only remove if they don't exist or need to be recreated
    self.view = [[PassthroughView alloc] 
        initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = UIColor.clearColor;
    self.view.multipleTouchEnabled = YES;
}
- (void)setupDisplayLink {
    CADisplayLink *dl = [CADisplayLink 
        displayLinkWithTarget:self 
                     selector:@selector(updateFrame)];
    [dl addToRunLoop:[NSRunLoop mainRunLoop] 
             forMode:NSRunLoopCommonModes];
}

- (void)setupGestureRecognizers {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] 
        initWithTarget:self action:@selector(handleOutsideTap:)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)updateFrame {




    get_players(); 
    aimbot(); 
    game_sdk->init();
 
       boxUIKIT(); 
       espUIKIT();
        distanceUIKIT(); 
        nameUIKIT(); 
        skeleton(); 
        enemyCountUIKIT();
  
    SpeedAuto();
         
        if (Vars.Glow) {
            renderGlow();
        }
    

 
        
 

    
    Vars.isAimFov = Vars.AimFov > 0;
    self.frameCount++;
}

- (void)setupFloatingPanel {
    panelWidth = 410;
    panelHeight = 350;
    CGPoint savedOrigin = [self loadPanelPosition];
    
    floatingPanel = [[UIView alloc] initWithFrame:CGRectMake(
        savedOrigin.x, savedOrigin.y, panelWidth, panelHeight)];
    floatingPanel.backgroundColor = [self backgroundColor];
    floatingPanel.layer.cornerRadius = 25;
    floatingPanel.clipsToBounds = YES;
    
    // Enhanced shadow with better depth
    floatingPanel.layer.shadowColor = [UIColor blackColor].CGColor;
    floatingPanel.layer.shadowOpacity = 0.7;
    floatingPanel.layer.shadowRadius = 35;
    floatingPanel.layer.shadowOffset = CGSizeMake(0, 18);
    floatingPanel.layer.masksToBounds = NO;
    
    // Add subtle border for better definition
    floatingPanel.layer.borderWidth = 1.0;
    floatingPanel.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.3] CGColor] : 
        [[UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.35] CGColor];
    
    [self.view addSubview:floatingPanel];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] 
        initWithTarget:self action:@selector(handleDrag:)];
    [floatingPanel addGestureRecognizer:pan];
}

- (void)setupSidebar {
    // Create a container view with clipping
    UIView *sidebarContainer = [[UIView alloc] initWithFrame:CGRectMake(
        0, 0, kSidebarWidth, panelHeight)];
    sidebarContainer.backgroundColor = [UIColor clearColor];
    sidebarContainer.clipsToBounds = YES;
    sidebarContainer.layer.masksToBounds = YES;
    
    // Add rounded corner mask to container
UIBezierPath *containerMaskPath = [UIBezierPath 
    bezierPathWithRoundedRect:sidebarContainer.bounds 
            byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                  cornerRadii:CGSizeMake(28, 28)];
    CAShapeLayer *containerMaskLayer = [CAShapeLayer layer];
    containerMaskLayer.path = containerMaskPath.CGPath;
    sidebarContainer.layer.mask = containerMaskLayer;
    
    [floatingPanel addSubview:sidebarContainer];
    
    // Create scroll view INSIDE the container
    self.sidebarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(
        0, 0, kSidebarWidth, panelHeight)];
    self.sidebarScrollView.backgroundColor = [UIColor clearColor];
    self.sidebarScrollView.showsVerticalScrollIndicator = NO;
    self.sidebarScrollView.bounces = YES;
    self.sidebarScrollView.clipsToBounds = NO; // Important!
    [sidebarContainer addSubview:self.sidebarScrollView];
    
    NSArray *icons = @[
        @"scope",              // AIMBOT - first tab
        @"eye.fill",           // ESP - second tab
        @"gamecontroller.fill", // MSL - third tab
        @"wrench.and.screwdriver.fill",          // WEAPONS - fourth tab
        @"person.fill"         // PROFILE - fifth tab
    ];
    CGFloat startY = 16;
    CGFloat totalHeight = startY + 
        (icons.count * (kTabIconSize + kTabSpacing)) + 16;
    
    self.sidebarView = [[UIView alloc] initWithFrame:CGRectMake(
        0, 0, kSidebarWidth, totalHeight)];
    self.sidebarView.backgroundColor = [UIColor clearColor];
    [self.sidebarScrollView addSubview:self.sidebarView];
    self.sidebarScrollView.contentSize = CGSizeMake(kSidebarWidth, totalHeight);
    
    for (int i = 0; i < icons.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(
            (kSidebarWidth - kTabIconSize) / 2, 
            startY + (i * (kTabIconSize + kTabSpacing)), 
            kTabIconSize, 
            kTabIconSize)];
        btn.backgroundColor = [self pillColor];
        btn.layer.cornerRadius = kTabIconSize / 2;
        btn.tag = i;
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(
            (kTabIconSize - kTabIconImageSize) / 2, 
            (kTabIconSize - kTabIconImageSize) / 2, 
            kTabIconImageSize, 
            kTabIconImageSize)];
        UIImage *img = [UIImage systemImageNamed:icons[i]];
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration 
            configurationWithPointSize:20 weight:UIImageSymbolWeightSemibold];
        iv.image = [img imageByApplyingSymbolConfiguration:cfg];
        iv.tintColor = (i == self.currentTab) ? 
            [self accentColor] : [self secondaryTextColor];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.tag = 100;
        [btn addSubview:iv];
        
        [btn addTarget:self 
                action:@selector(tabButtonTapped:) 
      forControlEvents:UIControlEventTouchUpInside];
        [self.sidebarView addSubview:btn];
        [self.tabButtons addObject:btn];
    }
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(
        kSidebarWidth - 1, 
        kSeparatorPadding, 
        1, 
        panelHeight - (kSeparatorPadding * 2))];
    separator.backgroundColor = isDarkMode ? 
        [UIColor colorWithWhite:0.3 alpha:0.5] : 
        [UIColor colorWithWhite:0.7 alpha:0.5];
    separator.tag = 3000;
    [floatingPanel addSubview:separator];
}

- (void)updateSidebarClipMask {
    if (!self.sidebarScrollView) return;
    
    UIBezierPath *maskPath = [UIBezierPath 
        bezierPathWithRoundedRect:self.sidebarScrollView.bounds 
                byRoundingCorners:UIRectCornerBottomLeft 
                      cornerRadii:CGSizeMake(28, 28)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    self.sidebarScrollView.layer.mask = maskLayer;
}
- (void)setupHeaderBar {
    CGFloat headerHeight = 48;
    CGFloat headerButtonWidth = 180;
    
    self.headerButton = [[UIButton alloc] initWithFrame:CGRectMake(
        kSidebarWidth + 8, 10, headerButtonWidth, headerHeight)];
    self.headerButton.backgroundColor = [self pillColor];
    self.headerButton.layer.cornerRadius = headerHeight / 2;
    // Removed tab selector popup - header button does nothing now
    self.headerButton.tag = 2000;
    [floatingPanel addSubview:self.headerButton];
    
    UIImageView *headerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(
        14, 12, 24, 24)];
    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration 
        configurationWithPointSize:18 weight:UIImageSymbolWeightBold];
    headerIcon.image = [[UIImage systemImageNamed:@"scope"] 
        imageByApplyingSymbolConfiguration:cfg];
    headerIcon.tintColor = [self accentColor];
    headerIcon.tag = 2001;
    [self.headerButton addSubview:headerIcon];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
        42, 0, headerButtonWidth - 42, headerHeight)];
    titleLabel.text = @"AIMBOT";
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    titleLabel.textColor = [self accentColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.tag = 2002;
    [self.headerButton addSubview:titleLabel];
    
    CGFloat btnSize = 44;
    
    // Theme toggle (dark/light only, no color picker)
    themeToggle = [UIButton buttonWithType:UIButtonTypeSystem];
    themeToggle.frame = CGRectMake(panelWidth - 98, 13, btnSize, btnSize);
    themeToggle.backgroundColor = [self pillColor];
    themeToggle.layer.cornerRadius = btnSize / 2;
    UIImage *themeImg = [UIImage systemImageNamed:isDarkMode ? 
                         @"moon.fill" : @"sun.max.fill"];
    [themeToggle setImage:themeImg forState:UIControlStateNormal];
    themeToggle.tintColor = [self accentColor];
    
    // Regular tap for dark/light toggle
    [themeToggle addTarget:self 
                    action:@selector(toggleTheme) 
          forControlEvents:UIControlEventTouchUpInside];
    
    [floatingPanel addSubview:themeToggle];
    
    // Close button
    closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(panelWidth - 54, 13, btnSize, btnSize);
    closeButton.backgroundColor = [self pillColor];
    closeButton.layer.cornerRadius = btnSize / 2;
    UIImage *closeImg = [UIImage systemImageNamed:@"xmark"];
    UIImageSymbolConfiguration *closeCfg = [UIImageSymbolConfiguration 
        configurationWithPointSize:14 weight:UIImageSymbolWeightBold];
    [closeButton setImage:[closeImg imageByApplyingSymbolConfiguration:closeCfg] 
                 forState:UIControlStateNormal];
    closeButton.tintColor = [self accentColor];
    [closeButton addTarget:self 
                    action:@selector(animateClose) 
          forControlEvents:UIControlEventTouchUpInside];
    [floatingPanel addSubview:closeButton];
    
}

- (void)updateAllColorsWithFade {
    // ===== MAIN PANEL =====
    floatingPanel.backgroundColor = [self backgroundColor];
    
    // Update panel border
    floatingPanel.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.3] CGColor] : 
        [[UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.35] CGColor];
    
    // ===== SCROLL INDICATOR =====
    self.contentScrollView.indicatorStyle = isDarkMode ? 
        UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleBlack;
    
    // ===== HEADER BUTTONS =====
    self.headerButton.backgroundColor = [self pillColor];
    themeToggle.backgroundColor = [self pillColor];
    closeButton.backgroundColor = [self pillColor];
    
    // ===== HEADER ICONS & TEXT =====
    UIImageView *headerIcon = [self.headerButton viewWithTag:2001];
    UILabel *titleLabel = [self.headerButton viewWithTag:2002];
    if (headerIcon) headerIcon.tintColor = [self accentColor];
    if (titleLabel) titleLabel.textColor = [self accentColor];
    
    themeToggle.tintColor = [self accentColor];
    closeButton.tintColor = [self accentColor];
    
    // ===== SIDEBAR BUTTONS =====
    for (UIButton *btn in self.tabButtons) {
        btn.backgroundColor = [self pillColor];
        UIImageView *icon = [btn viewWithTag:100];
        if (icon && btn.tag == self.currentTab) {
            icon.tintColor = [self accentColor];
        }
    }
    
    // ===== SEPARATOR =====
    UIView *separator = [floatingPanel viewWithTag:3000];
    if (separator) {
        separator.backgroundColor = isDarkMode ? 
            [UIColor colorWithWhite:0.3 alpha:0.5] : 
            [UIColor colorWithWhite:0.7 alpha:0.5];
    }
    
    // ===== UPDATE ALL CONTENT PILLS =====
    [self updateAllContentColors];
}

- (void)updateAllContentColors {
    // Iterate through all content
    for (UIView *subview in self.contentContainer.subviews) {
        
        // ===== FEATURE PILLS =====
        if (subview.tag >= 1000 && [subview isKindOfClass:[UIView class]]) {
            // Update pill background
            subview.backgroundColor = [self pillColor];
            
            // Update pill border
            subview.layer.borderColor = isDarkMode ? 
                [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
                [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
            
            // Update glow color if pill is active
            if (subview.layer.shadowOpacity > 0) {
                subview.layer.shadowColor = [self glowColor].CGColor;
            }

            UIView *triggerContainer = [self.contentContainer viewWithTag:77001];
if (triggerContainer) {
    triggerContainer.backgroundColor = [self pillColor];
    triggerContainer.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    
    UIView *indicator = [triggerContainer viewWithTag:9001];
    if (indicator) {
        indicator.backgroundColor = [self accentColor];
        indicator.layer.shadowColor = [self glowColor].CGColor;
    }
    
    NSInteger currentIndex = Vars.AimWhen;
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [triggerContainer viewWithTag:20000 + i];
        UILabel *lbl = [btn viewWithTag:100];
        lbl.textColor = (i == currentIndex) ? [UIColor whiteColor] : [self textColor];
    }
}

// Update Target Bone segment
UIView *targetContainer = [self.contentContainer viewWithTag:77002];
if (targetContainer) {
    targetContainer.backgroundColor = [self pillColor];
    targetContainer.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    
    UIView *indicator = [targetContainer viewWithTag:9002];
    if (indicator) {
        indicator.backgroundColor = [self accentColor];
        indicator.layer.shadowColor = [self glowColor].CGColor;
    }
    
    NSInteger currentIndex = (NSInteger)Vars.Target;
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [targetContainer viewWithTag:30000 + i];
        UILabel *lbl = [btn viewWithTag:100];
        lbl.textColor = (i == currentIndex) ? [UIColor whiteColor] : [self textColor];
    }
}
            
            // Update children (labels, checkboxes)
            for (UIView *child in subview.subviews) {
                if ([child isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)child;
                    label.textColor = [self textColor];
                } else if ([child isKindOfClass:[UIButton class]]) {
                    UIButton *checkbox = (UIButton *)child;
                    // Update checkbox if it's checked
                    CGFloat r, g, b, a;
                    [checkbox.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
                    // If not the "off" color, it's checked - update to new accent
                    UIColor *offColor = [self checkboxOffColor];
                    CGFloat offR, offG, offB, offA;
                    [offColor getRed:&offR green:&offG blue:&offB alpha:&offA];
                    if (fabs(r - offR) > 0.1 || fabs(g - offG) > 0.1 || fabs(b - offB) > 0.1) {
                        checkbox.backgroundColor = [self accentColor];
                    }
                }
            }
        }
        
        // ===== SECTION LABELS =====
        else if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if (label.font.pointSize == 13) { // Section label size
                label.textColor = [self secondaryTextColor];
            } else if (label.font.pointSize == 14 || label.font.pointSize == 15) {
                label.textColor = [self textColor];
            }
        }
        
        // ===== SEGMENT CONTROLS =====
        else if ([subview isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *seg = (UISegmentedControl *)subview;
            seg.selectedSegmentTintColor = [self accentColor];
            [seg setTitleTextAttributes:@{
                NSForegroundColorAttributeName: [self textColor]
            } forState:UIControlStateNormal];
            [seg setTitleTextAttributes:@{
                NSForegroundColorAttributeName: [UIColor whiteColor]
            } forState:UIControlStateSelected];
        }
        else if ([subview isKindOfClass:[UIView class]] && 
         [subview viewWithTag:9500] != nil) {
    
    // Update container background
    subview.backgroundColor = [self pillColor];
    subview.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    
    // Update indicator color
    UIView *indicator = [subview viewWithTag:9500];
    if (indicator) {
        indicator.backgroundColor = [self accentColor];
        indicator.layer.shadowColor = [self glowColor].CGColor;
    }
    
    // Update button labels
    NSNumber *leftActiveNum = objc_getAssociatedObject(subview, "leftActive");
    NSNumber *rightActiveNum = objc_getAssociatedObject(subview, "rightActive");
    BOOL leftActive = leftActiveNum ? [leftActiveNum boolValue] : NO;
    BOOL rightActive = rightActiveNum ? [rightActiveNum boolValue] : NO;
    
    UIButton *leftBtn = [subview viewWithTag:11000];
    UIButton *rightBtn = [subview viewWithTag:11001];
    
    if (leftBtn) {
        UILabel *leftLabel = [leftBtn viewWithTag:100];
        if (leftLabel) {
            leftLabel.textColor = leftActive ? [UIColor whiteColor] : [self textColor];
        }
    }
    
    if (rightBtn) {
        UILabel *rightLabel = [rightBtn viewWithTag:100];
        if (rightLabel) {
            rightLabel.textColor = rightActive ? [UIColor whiteColor] : [self textColor];
        }
    }
}
        // ===== BUTTON PILLS =====
        else if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subview;
            // Check if it's an active button pill (has glow)
            if (btn.layer.shadowOpacity > 0.5) {
                btn.backgroundColor = [self accentColor];
                btn.layer.shadowColor = [self glowColor].CGColor;
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                btn.backgroundColor = [self pillColor];
                [btn setTitleColor:[self textColor] forState:UIControlStateNormal];
            }
        }
       else if ([subview isKindOfClass:[UIView class]] && 
         [subview viewWithTag:9000] != nil) {
    
    // Update container background
    subview.backgroundColor = [self pillColor];
    subview.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    
    // Get stored values
    NSNumber *currentIndexNum = objc_getAssociatedObject(subview, "currentIndex");
    NSNumber *buttonWidthNum = objc_getAssociatedObject(subview, "buttonWidth");
    NSInteger currentIndex = currentIndexNum ? [currentIndexNum integerValue] : 0;
    CGFloat buttonWidth = buttonWidthNum ? [buttonWidthNum floatValue] : 100.0;
    
    // Update sliding indicator - REPOSITION IT
    UIView *indicator = [subview viewWithTag:9000];
    if (indicator) {
        // Set correct position without animation
        CGFloat correctX = 4 + (buttonWidth * currentIndex);
        indicator.frame = CGRectMake(correctX, 4, buttonWidth, 
                                     subview.frame.size.height - 8);
        indicator.backgroundColor = [self accentColor];
        indicator.layer.shadowColor = [self glowColor].CGColor;
    }
    
    // Update button labels
    for (UIView *child in subview.subviews) {
        if ([child isKindOfClass:[UIButton class]] && child.tag >= 10000) {
            UIButton *btn = (UIButton *)child;
            NSNumber *btnIndexNum = objc_getAssociatedObject(btn, "segmentIndex");
            NSInteger btnIndex = btnIndexNum ? [btnIndexNum integerValue] : 0;
            UILabel *label = [btn viewWithTag:100];
            
            if (label) {
                BOOL isSelected = (btnIndex == currentIndex);
                label.textColor = isSelected ? 
                    [UIColor whiteColor] : [self textColor];
                label.font = [UIFont systemFontOfSize:13 
                    weight:isSelected ? UIFontWeightBold : UIFontWeightSemibold];
            }
        }
    }
}      // ===== SLIDER PILLS =====
        else if ([subview isKindOfClass:[UIView class]]) {
            // Check if it contains a slider
            for (UIView *child in subview.subviews) {
                if ([child isKindOfClass:[UISlider class]]) {
                    // This is a slider pill
                    subview.backgroundColor = [self pillColor];
                    
                    UISlider *slider = (UISlider *)child;
                    slider.minimumTrackTintColor = [self accentColor];
                    slider.maximumTrackTintColor = isDarkMode ? 
                        [UIColor colorWithWhite:0.3 alpha:1] : 
                        [UIColor colorWithWhite:0.65 alpha:1];
                    
                    // Update labels in slider pill
                    for (UIView *pillChild in subview.subviews) {
                        if ([pillChild isKindOfClass:[UILabel class]]) {
                            UILabel *label = (UILabel *)pillChild;
                            if (label.tag == 600) { // Value label
                                label.textColor = [self accentColor];
                            } else {
                                label.textColor = [self textColor];
                            }
                        }
                    }
                }
            }
        }
        
        // ===== PROFILE TAB LABELS =====
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            // Update secondary text color for titles
            if (label.font.pointSize == 14 && label.frame.size.width == 80) {
                label.textColor = [self secondaryTextColor];
            }
            // Update value labels with accent color
            else if (label.font.pointSize == 16 || 
                     (label.font.pointSize == 14 && label.frame.size.width > 100)) {
                // Keep special colors (green for FPS, red/green for status)
                if (![label.textColor isEqual:[UIColor systemGreenColor]] &&
                    ![label.textColor isEqual:[UIColor systemRedColor]]) {
                    label.textColor = [self textColor];
                }
            }
        }
    }
    
    // Force layout update
    [self.contentContainer setNeedsLayout];
    [self.contentContainer layoutIfNeeded];
}
- (CGFloat)addWarningLabel:(NSString *)warningText 
                       atY:(CGFloat)y 
                     width:(CGFloat)w 
                   padding:(CGFloat)p {
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(
        p + 18, y, w - 36, 0)]; // Height will auto-adjust
    warningLabel.text = warningText;
    warningLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    warningLabel.textColor = [UIColor systemOrangeColor];
    warningLabel.numberOfLines = 0; // Multi-line support
    [warningLabel sizeToFit];
    
    [self.contentContainer addSubview:warningLabel];
    
    return y + warningLabel.frame.size.height + 8; // Return updated Y position
}
// Helper method to compare colors
- (BOOL)isColor:(UIColor *)color1 similarTo:(UIColor *)color2 {
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat threshold = 0.15;
    return (fabs(r1 - r2) < threshold && 
            fabs(g1 - g2) < threshold && 
            fabs(b1 - b2) < threshold);
}

- (void)setupContentArea {
    CGFloat headerHeight = 70;
    CGFloat contentWidth = panelWidth - kSidebarWidth;
    CGFloat contentHeight = panelHeight - headerHeight;
    
    UIView *contentClipView = [[UIView alloc] initWithFrame:CGRectMake(
        kSidebarWidth, headerHeight, contentWidth, contentHeight)];
    contentClipView.backgroundColor = [UIColor clearColor];
    contentClipView.clipsToBounds = YES;
    contentClipView.layer.masksToBounds = YES;
    
    UIBezierPath *maskPath = [UIBezierPath 
        bezierPathWithRoundedRect:contentClipView.bounds 
                byRoundingCorners:UIRectCornerBottomRight 
                      cornerRadii:CGSizeMake(28, 28)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    contentClipView.layer.mask = maskLayer;
    
    contentClipView.tag = 4000;
    [floatingPanel addSubview:contentClipView];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(
        0, 0, contentWidth, contentHeight)];
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    self.contentScrollView.showsVerticalScrollIndicator = YES;
    self.contentScrollView.indicatorStyle = isDarkMode ? 
        UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleBlack;
    self.contentScrollView.contentInset = UIEdgeInsetsMake(
        kContentTopInset, 0, kContentBottomInset, 0);
    self.contentScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(
        kContentTopInset, 0, kContentBottomInset, 0);
    self.contentScrollView.clipsToBounds = YES;
    self.contentScrollView.bounces = YES;
    [contentClipView addSubview:self.contentScrollView];
    
    self.contentContainer = [[UIView alloc] initWithFrame:CGRectMake(
        0, 0, contentWidth, contentHeight)];
    self.contentContainer.backgroundColor = [UIColor clearColor];
    [self.contentScrollView addSubview:self.contentContainer];
    
    [self updateContentClipMask];
}

- (void)updateContentClipMask {
    UIView *contentClipView = [floatingPanel viewWithTag:4000];
    if (!contentClipView) return;
    
    UIBezierPath *maskPath = [UIBezierPath 
        bezierPathWithRoundedRect:contentClipView.bounds 
                byRoundingCorners:UIRectCornerBottomRight 
                      cornerRadii:CGSizeMake(28, 28)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    contentClipView.layer.mask = maskLayer;
}


#pragma mark - Save/Load Popup

#pragma mark - Tab Selector Popup

- (void)showTabSelector {
    // Popup removed - do nothing
    return;
}

- (void)hideTabSelector {
    if (!self.tabSelectorPopup) return;
    [UIView animateWithDuration:0.2 animations:^{
        self.tabSelectorPopup.alpha = 0;
        self.tabSelectorPopup.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL f) { 
        [self.tabSelectorPopup removeFromSuperview]; 
        self.tabSelectorPopup = nil; 
    }];
}

- (void)tabOptionSelected:(UIButton *)sender {
    // Prevent race conditions
    if (self.isChangingTab) {
        return;
    }
    
    [self hideTabSelector];
    MenuTab selectedTab = (MenuTab)sender.tag;
    if (selectedTab != self.currentTab) {
        self.currentTab = selectedTab;
        [self saveUIState]; // Save tab change
        [self updateSidebarForTab:selectedTab];
        [self updateHeaderForTab:selectedTab];
        [self loadTabContent:selectedTab];
    }
}

- (void)tabButtonTapped:(UIButton *)sender {
    // Prevent race conditions
    if (self.isChangingTab) {
        return;
    }
    
    MenuTab selectedTab = (MenuTab)sender.tag;
    if (selectedTab == self.currentTab) return;
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    [UIView animateWithDuration:0.15 animations:^{
        sender.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            sender.transform = CGAffineTransformIdentity;
        }];
    }];
    
    self.currentTab = selectedTab;
    [self saveUIState]; // Save tab change
    [self updateSidebarForTab:selectedTab];
    [self updateHeaderForTab:selectedTab];
    [self loadTabContent:selectedTab];
}

- (void)updateSidebarForTab:(MenuTab)tab {
    for (UIButton *btn in self.tabButtons) {
        UIImageView *iv = [btn viewWithTag:100];
        BOOL isSelected = (btn.tag == tab);
        
        [UIView animateWithDuration:0.3 animations:^{
            iv.tintColor = isSelected ? 
                [self accentColor] : [self secondaryTextColor];
            iv.transform = isSelected ? 
                CGAffineTransformMakeScale(1.15, 1.15) : 
                CGAffineTransformIdentity;
        }];
    }
}

- (NSString *)localizedString:(NSString *)english portuguese:(NSString *)portuguese {
    return (self.currentLanguage == 1) ? portuguese : english;
}

- (void)updateHeaderForTab:(MenuTab)tab {
    NSArray *titlesEN = @[@"AIMBOT", @"ESP", @"MSL", @"WEAPONS", @"PROFILE"];
    NSArray *titlesPT = @[@"FUNÇÕES", @"ESP", @"EXTRAS", @"ARMAS", @"PERFIL"];
    NSArray *icons = @[
        @"scope",              // AIMBOT - first tab
        @"eye.fill",           // ESP - second tab
        @"gamecontroller.fill", // MSL - third tab
        @"wrench.and.screwdriver.fill",          // WEAPONS - fourth tab
        @"person.fill"         // PROFILE - fifth tab
    ];
    UIImageView *headerIcon = [self.headerButton viewWithTag:2001];
    UILabel *titleLabel = [self.headerButton viewWithTag:2002];
    
    NSString *title = (self.currentLanguage == 1) ? titlesPT[tab] : titlesEN[tab];
    
    [UIView transitionWithView:self.headerButton 
                      duration:0.25 
                       options:UIViewAnimationOptionTransitionCrossDissolve 
                    animations:^{
        headerIcon.image = [[UIImage systemImageNamed:icons[tab]] 
            imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration 
                configurationWithPointSize:18 weight:UIImageSymbolWeightBold]];
        titleLabel.text = title;
        titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    } completion:nil];
}

- (void)loadTabContent:(MenuTab)tab {
    // Prevent race conditions - if already changing, ignore
    if (self.isChangingTab) {
        return;
    }
    self.isChangingTab = YES;
    
    [UIView animateWithDuration:0.15 animations:^{ 
        self.contentContainer.alpha = 0.0;
        self.contentContainer.transform = CGAffineTransformMakeTranslation(0, 10);
    } completion:^(BOOL f) {
        // Double-check we're still supposed to load this tab
        if (self.isChangingTab == NO) {
            return; // Another change happened, abort
        }
        
        for (UIView *sv in self.contentContainer.subviews) {
            [sv removeFromSuperview];
        }
        
        CGFloat y = 6;
        CGFloat w = self.contentScrollView.frame.size.width - 16;
        CGFloat p = kContentPadding;
        switch (tab) {
            case MenuTabAimbot: 
                y = [self createAimbotContent:y width:w padding:p]; 
                break;
            case MenuTabESP: 
                y = [self createESPContent:y width:w padding:p]; 
                break;
            case MenuTabMSL: 
                y = [self createMSLContent:y width:w padding:p]; 
                break;
            case MenuTabWeapons: 
                y = [self createWeaponsContent:y width:w padding:p]; 
                break;
            case MenuTabProfile: 
                y = [self createProfileContent:y width:w padding:p]; 
                break;
        }
        
        self.contentContainer.frame = CGRectMake(
            0, 0, self.contentScrollView.frame.size.width, y + 12);
        self.contentScrollView.contentSize = CGSizeMake(
            self.contentScrollView.frame.size.width, y + 12);
        self.contentContainer.transform = CGAffineTransformMakeTranslation(
            0, -10);
        
        [UIView animateWithDuration:0.25 
                              delay:0 
             usingSpringWithDamping:0.9 
              initialSpringVelocity:0.5 
                            options:0 
                         animations:^{ 
            self.contentContainer.alpha = 1.0;
            self.contentContainer.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.isChangingTab = NO;
        }];
    }];
}

- (CGFloat)createWeaponsContent:(CGFloat)startY 
                         width:(CGFloat)w 
                       padding:(CGFloat)p {
    CGFloat y = startY;
    BOOL isPT = (self.currentLanguage == 1);
    
    y = [self addFeaturePillWithDescription:isPT ? @"Troca Rápida" : @"Fast Switch" 
                                      key:@"FastSwitch" 
                                    value:FastSwitch 
                                 selector:@selector(toggleFastSwitch:) 
                                 description:isPT ? @"Troca armas instantaneamente sem delay" : @"Instantly switches weapons without delay"
                                      atY:y width:w padding:p];
    
    return y;
}

#pragma mark - Content Creators

- (CGFloat)createESPContent:(CGFloat)startY 
                      width:(CGFloat)w 
                    padding:(CGFloat)p {
    CGFloat y = startY;
    BOOL isPT = (self.currentLanguage == 1);
    
    y = [self addFeaturePill:isPT ? @"Ativar Esp" : @"Enable" 
                         key:@"Enable" 
                       value:Vars.Enable 
                    selector:@selector(toggleEnable:) 
                         atY:y width:w padding:p];
    y = [self addFeaturePill:isPT ? @"Caixa ESP" : @"ESP Box" 
                         key:@"Box" 
                       value:Vars.Box 
                    selector:@selector(toggleBox:) 
                         atY:y width:w padding:p];
    y = [self addFeaturePill:isPT ? @"Linhas ESP" : @"ESP Lines" 
                         key:@"Lines" 
                       value:Vars.lines 
                    selector:@selector(toggleLines:) 
                         atY:y width:w padding:p];
    y = [self addFeaturePillWithDescription:isPT ? @"Esqueleto" : @"Skeleton" 
                                      key:@"Skeleton" 
                                    value:Vars.Skeleton 
                                 selector:@selector(toggleSkeleton:) 
                                 description:isPT ? @"Mostra estrutura óssea do jogador" : @"Shows player skeleton/bone structure"
                                      atY:y width:w padding:p];
    y = [self addFeaturePillWithDescription:isPT ? @"Vida" : @"Health" 
                                      key:@"Health" 
                                    value:Vars.Health 
                                 selector:@selector(toggleHealth:) 
                                 description:isPT ? @"Exibe barra de vida acima do ESP" : @"Displays player health bar above ESP"
                                      atY:y width:w padding:p];
    y = [self addFeaturePillWithDescription:isPT ? @"Distância" : @"Distance" 
                                      key:@"Distance" 
                                    value:Vars.Distance 
                                 selector:@selector(toggleDistance:) 
                                 description:isPT ? @"Mostra distância até jogadores em metros" : @"Shows distance to players in meters"
                                      atY:y width:w padding:p];
    y = [self addFeaturePillWithDescription:isPT ? @"Nome ESP" : @"ESP Name" 
                                      key:@"Name" 
                                    value:Vars.Name 
                                 selector:@selector(toggleName:) 
                                 description:isPT ? @"Mostra nomes dos jogadores acima das caixas ESP" : @"Shows player names above ESP boxes"
                                      atY:y width:w padding:p];
    y = [self addFeaturePillWithDescription:isPT ? @"Contorno ESP" : @"ESP Outline" 
                                      key:@"Outline" 
                                    value:Vars.Outline 
                                 selector:@selector(toggleOutline:) 
                                 description:isPT ? @"Adiciona borda ao redor das caixas ESP" : @"Adds outline border around ESP boxes"
                                      atY:y width:w padding:p];
    y = [self addFeaturePillWithDescription:isPT ? @"Contagem Inimigos" : @"EnemyCount" 
                                      key:@"EnemyCount" 
                                    value:Vars.enemycount 
                                 selector:@selector(toggleenemycount:) 
                                 description:isPT ? @"Mostra número total de inimigos próximos" : @"Shows total number of nearby enemies"
                                      atY:y width:w padding:p];
    
    y = [self addFeaturePillWithDescription:isPT ? @"Efeito Brilho" : @"Glow Effect" 
                                      key:@"Glow" 
                                    value:Vars.Glow 
                                 selector:@selector(toggleGlow:) 
                                 description:isPT ? @"Adiciona contorno brilhante ao redor dos inimigos" : @"Adds glowing outline around enemies"
                                      atY:y width:w padding:p];
    
    // ESP Color Selection
    y = [self addSectionLabel:isPT ? @"Cores ESP" : @"ESP Colors" 
                          atY:y width:w padding:p];
    
    y = [self addColorPickerSegment:isPT ? @"Cor Linha" : @"Line Color" 
                         colorType:0 
                              atY:y width:w padding:p];
    
    y = [self addColorPickerSegment:isPT ? @"Cor Caixa" : @"Box Color" 
                         colorType:1 
                              atY:y width:w padding:p];
    
    y = [self addColorPickerSegment:isPT ? @"Cor Esqueleto" : @"Skeleton Color" 
                         colorType:2 
                              atY:y width:w padding:p];
    
    y = [self addColorPickerSegment:isPT ? @"Cor Nome" : @"Name Color" 
                         colorType:3 
                              atY:y width:w padding:p];
    
    return y;
}

- (CGFloat)createAimbotContent:(CGFloat)startY 
                         width:(CGFloat)w 
                       padding:(CGFloat)p {
    CGFloat y = startY;
    BOOL isPT = (self.currentLanguage == 1);
    
    y = [self addFeaturePill:isPT ? @"Aimbot" : @"Aimbot" 
                         key:@"Aimbot" 
                       value:Vars.Aimbot 
                    selector:@selector(toggleAimbot:) 
                         atY:y width:w padding:p];
    
    y = [self addFeaturePillWithDescription:isPT ? @"Puxar em Paredes" : @"Aim Visible" 
                                      key:@"AimVisible" 
                                    value:Vars.Aimsilent69 
                                 selector:@selector(toggleAimVisible:) 
                                 description:isPT ? @"Mostra mira em killcam e replays" : @"Shows aimbot in killcam and replays"
                                      atY:y width:w padding:p];
    
    y = [self addFeaturePillWithDescription:isPT ? @"AimKill" : @"Aim Kill" 
                                      key:@"AimKill" 
                                    value:Vars.playertakedamage2T 
                                 selector:@selector(toggleAimKill:) 
                                 description:isPT ? @"Mata inimigos automaticamente ao mirar" : @"Automatically kills enemies when aiming at them"
                                      atY:y width:w padding:p];
    
    y = [self addFeaturePill:isPT ? @"Ignorar Bot" : @"Ignore Bot" 
                         key:@"IgnoreBot" 
                       value:IgnoreBot 
                    selector:@selector(toggleIgnoreBot:) 
                         atY:y width:w padding:p];
    
    y = [self addFeaturePill:isPT ? @"Ignorar Derrubados" : @"Ignore Knocked" 
                         key:@"IgnoreKnocked2" 
                       value:IgnoreKnocked2 
                    selector:@selector(toggleIgnoreKnocked2:) 
                         atY:y width:w padding:p];
    
    y = [self addSliderPill:isPT ? @"Raio FOV" : @"FOV Radius" 
                      value:Vars.AimFov 
                        min:0 
                        max:500 
                   selector:@selector(sliderChanged:) 
                        atY:y width:w padding:p];
    
    y = [self addSliderPill:isPT ? @"Espessura FOV" : @"FOV Thickness" 
                      value:AimbotFOVThickness 
                        min:0.1 
                        max:5.0 
                   selector:@selector(fovThicknessChanged:) 
                        atY:y width:w padding:p];
    
    y = [self addColorPickerSegment:isPT ? @"Cor FOV" : @"FOV Color" 
                         colorType:4 
                              atY:y width:w padding:p];
    
    y = [self addSectionLabel:isPT ? @"Tipo De Aimbot" : @"Trigger When" 
                          atY:y width:w padding:p];
    y = [self addTriggerWhenSegment:y width:w padding:p];
    
    y = [self addSectionLabel:isPT ? @"Puxada" : @"Target Bone" 
                          atY:y width:w padding:p];
    y = [self addTargetBoneSegment:y width:w padding:p];
    
    y = [self addSectionLabel:isPT ? @"Prioridade Alvo" : @"Target Priority" 
                          atY:y width:w padding:p];
    y = [self addTargetPrioritySegment:y width:w padding:p];
    
    return y;
}
















- (CGFloat)createMSLContent:(CGFloat)startY 
                      width:(CGFloat)w 
                    padding:(CGFloat)p {
    CGFloat y = startY;
    BOOL isPT = (self.currentLanguage == 1);
    
    y = [self addFeaturePillWithDescription:isPT ? @"Speed" : @"Speed Bypass" 
                                      key:@"SpeedHack" 
                                    value:SpeedHack 
                                 selector:@selector(toggleSpeedHack:) 
                                 description:isPT ? @"Aumenta velocidade de movimento além dos limites normais" : @"Increases movement speed beyond normal limits"
                                      atY:y width:w padding:p];
    
    y = [self addFeaturePillWithDescription:isPT ? @"Voar Player" : @"Up Player" 
                                      key:@"UpPlayer" 
                                    value:Vars.UpPlayer 
                                 selector:@selector(toggleUpPlayer:) 
                                 description:isPT ? @"Eleva posição do jogador acima do chão" : @"Elevates player position above ground"
                                      atY:y width:w padding:p];
    
    y = [self addFeaturePillWithDescription:isPT ? @"Teleport 8m" : @"Telekill 8m" 
                                      key:@"Teleport8m" 
                                    value:Vars.Telekill 
                                 selector:@selector(toggleTeleport8m:) 
                                 description:isPT ? @"Teleporta inimigos dentro de 8m para frente" : @"Teleports enemies within 8m forward"
                                      atY:y width:w padding:p];
    
    y = [self addFeaturePillWithDescription:isPT ? @"Esconder Painel" : @"Stream Mode" 
                                      key:@"StreamMode" 
                                    value:StreamMode 
                                 selector:@selector(toggleStreamMode:) 
                                 description:isPT ? @"Oculta elementos da interface durante captura de tela" : @"Hides UI elements during screen capture"
                                      atY:y width:w padding:p];
    
    y = [self addFeaturePillWithDescription:isPT ? @"Apagar Convidado" : @"Reset Guest" 
                                      key:@"ResetGuest" 
                                    value:Guest2 
                                 selector:@selector(toggleResetGuest:) 
                                 description:isPT ? @"Redefine dados e configurações da conta convidada" : @"Resets guest account data and settings"
                                      atY:y width:w padding:p];



    y = [self addFeaturePillWithDescription:isPT ? @"Apagar Convidado" : @"Fast Medkit" 
                                      key:@"fmedkit" 
                                    value:fmedkit 
                                 selector:@selector(toggleFastMedkit:) 
                                 description:isPT ? @"Fast Medkit" : @"Fast Medkit"
                                      atY:y width:w padding:p];


    
    return y;
}

- (CGFloat)addTriggerWhenSegment:(CGFloat)y width:(CGFloat)w padding:(CGFloat)p {
    CGFloat segmentHeight = 44;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(p, y, w, segmentHeight)];
    container.backgroundColor = [self pillColor];
    container.layer.cornerRadius = segmentHeight / 2;
    container.layer.borderWidth = 1.0;
    container.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    container.tag = 77001; // Unique tag
    [self.contentContainer addSubview:container];
    
    BOOL isPT = (self.currentLanguage == 1);
    NSArray *titles = isPT ? @[@"Sempre", @"Atirando", @"Mira"] : @[@"Always", @"Firing", @"Scope"];
    CGFloat buttonWidth = (w - 8) / 3.0;
    
    // READ DIRECTLY FROM VARS
    NSInteger currentIndex = Vars.AimWhen;
    if (currentIndex < 0 || currentIndex > 2) currentIndex = 0;
    
    // Indicator at correct position
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(
        4 + (buttonWidth * currentIndex), 4, buttonWidth, segmentHeight - 8)];
    indicator.backgroundColor = [self accentColor];
    indicator.layer.cornerRadius = (segmentHeight - 8) / 2;
    indicator.tag = 9001;
    indicator.layer.shadowColor = [self glowColor].CGColor;
    indicator.layer.shadowRadius = 8;
    indicator.layer.shadowOpacity = 0.6;
    indicator.layer.shadowOffset = CGSizeZero;
    [container addSubview:indicator];
    
    // Create 3 buttons
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(
            4 + (buttonWidth * i), 4, buttonWidth, segmentHeight - 8)];
        btn.tag = 20000 + i;
        btn.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:btn.bounds];
        lbl.text = titles[i];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:13 
            weight:(i == currentIndex) ? UIFontWeightBold : UIFontWeightSemibold];
        lbl.textColor = (i == currentIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.tag = 100;
        [btn addSubview:lbl];
        
        [btn addTarget:self 
                action:@selector(triggerSegmentTapped:) 
      forControlEvents:UIControlEventTouchUpInside];
        
        [container addSubview:btn];
    }
    
    return y + segmentHeight + kPillSpacing;
}

- (void)triggerSegmentTapped:(UIButton *)sender {
    NSInteger newIndex = sender.tag - 20000;
    if (newIndex < 0 || newIndex > 2) return;
    
    // WRITE DIRECTLY TO VARS
    Vars.AimWhen = (int)newIndex;
    
    // Find container
    UIView *container = [self.contentContainer viewWithTag:77001];
    if (!container) return;
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    // Move indicator
    UIView *indicator = [container viewWithTag:9001];
    CGFloat buttonWidth = (container.frame.size.width - 8) / 3.0;
    
    [UIView animateWithDuration:0.3 
                          delay:0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:1.0 
                        options:0 
                     animations:^{
        indicator.frame = CGRectMake(4 + (buttonWidth * newIndex), 4, 
                                     buttonWidth, container.frame.size.height - 8);
    } completion:nil];
    
    // Update labels
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [container viewWithTag:20000 + i];
        UILabel *lbl = [btn viewWithTag:100];
        lbl.textColor = (i == newIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.font = [UIFont systemFontOfSize:13 
            weight:(i == newIndex) ? UIFontWeightBold : UIFontWeightSemibold];
    }
}

- (CGFloat)addTargetBoneSegment:(CGFloat)y width:(CGFloat)w padding:(CGFloat)p {
    CGFloat segmentHeight = 44;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(p, y, w, segmentHeight)];
    container.backgroundColor = [self pillColor];
    container.layer.cornerRadius = segmentHeight / 2;
    container.layer.borderWidth = 1.0;
    container.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    container.tag = 77002; // Unique tag
    [self.contentContainer addSubview:container];
    
    BOOL isPT = (self.currentLanguage == 1);
    NSArray *titles = isPT ? @[@"Cabeça", @"Pescoço", @"Corpo"] : @[@"Head", @"Neck", @"Body"];
    CGFloat buttonWidth = (w - 8) / 3.0;
    
    // READ DIRECTLY FROM VARS
    NSInteger currentIndex = (NSInteger)Vars.Target;
    if (currentIndex < 0 || currentIndex > 2) currentIndex = 0;
    
    // Indicator at correct position
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(
        4 + (buttonWidth * currentIndex), 4, buttonWidth, segmentHeight - 8)];
    indicator.backgroundColor = [self accentColor];
    indicator.layer.cornerRadius = (segmentHeight - 8) / 2;
    indicator.tag = 9002;
    indicator.layer.shadowColor = [self glowColor].CGColor;
    indicator.layer.shadowRadius = 8;
    indicator.layer.shadowOpacity = 0.6;
    indicator.layer.shadowOffset = CGSizeZero;
    [container addSubview:indicator];
    
    // Create 3 buttons
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(
            4 + (buttonWidth * i), 4, buttonWidth, segmentHeight - 8)];
        btn.tag = 30000 + i;
        btn.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:btn.bounds];
        lbl.text = titles[i];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:13 
            weight:(i == currentIndex) ? UIFontWeightBold : UIFontWeightSemibold];
        lbl.textColor = (i == currentIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.tag = 100;
        [btn addSubview:lbl];
        
        [btn addTarget:self 
                action:@selector(targetSegmentTapped:) 
      forControlEvents:UIControlEventTouchUpInside];
        
        [container addSubview:btn];
    }
    
    return y + segmentHeight + kPillSpacing;
}

- (void)targetSegmentTapped:(UIButton *)sender {
    NSInteger newIndex = sender.tag - 30000;
    if (newIndex < 0 || newIndex > 2) return;
    
    // WRITE DIRECTLY TO VARS
    Vars.Target = (AimTarget)newIndex;
    
    // Find container
    UIView *container = [self.contentContainer viewWithTag:77002];
    if (!container) return;
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    // Move indicator
    UIView *indicator = [container viewWithTag:9002];
    CGFloat buttonWidth = (container.frame.size.width - 8) / 3.0;
    
    [UIView animateWithDuration:0.3 
                          delay:0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:1.0 
                        options:0 
                     animations:^{
        indicator.frame = CGRectMake(4 + (buttonWidth * newIndex), 4, 
                                     buttonWidth, container.frame.size.height - 8);
    } completion:nil];
    
    // Update labels
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [container viewWithTag:30000 + i];
        UILabel *lbl = [btn viewWithTag:100];
        lbl.textColor = (i == newIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.font = [UIFont systemFontOfSize:13 
            weight:(i == newIndex) ? UIFontWeightBold : UIFontWeightSemibold];
    }
}

- (CGFloat)addTargetPrioritySegment:(CGFloat)y width:(CGFloat)w padding:(CGFloat)p {
    CGFloat segmentHeight = 44;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(p, y, w, segmentHeight)];
    container.backgroundColor = [self pillColor];
    container.layer.cornerRadius = segmentHeight / 2;
    container.layer.borderWidth = 1.0;
    container.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    container.tag = 77003; // Unique tag for priority segment
    [self.contentContainer addSubview:container];
    
    BOOL isPT = (self.currentLanguage == 1);
    NSArray *titles = isPT ? @[@"Mais Próximo", @"Menor HP", @"Tiro na Cabeça"] : @[@"Closest", @"Lowest HP", @"Headshot"];
    CGFloat buttonWidth = (w - 8) / 3.0;
    
    // READ DIRECTLY FROM VARS
    NSInteger currentIndex = Vars.TargetPriority;
    if (currentIndex < 0 || currentIndex > 2) currentIndex = 0;
    
    // Indicator at correct position
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(
        4 + (buttonWidth * currentIndex), 4, buttonWidth, segmentHeight - 8)];
    indicator.backgroundColor = [self accentColor];
    indicator.layer.cornerRadius = (segmentHeight - 8) / 2;
    indicator.tag = 9003;
    indicator.layer.shadowColor = [self glowColor].CGColor;
    indicator.layer.shadowRadius = 8;
    indicator.layer.shadowOpacity = 0.6;
    indicator.layer.shadowOffset = CGSizeZero;
    [container addSubview:indicator];
    
    // Create 3 buttons
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(
            4 + (buttonWidth * i), 4, buttonWidth, segmentHeight - 8)];
        btn.tag = 31000 + i;
        btn.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:btn.bounds];
        lbl.text = titles[i];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:12 
            weight:(i == currentIndex) ? UIFontWeightBold : UIFontWeightSemibold];
        lbl.textColor = (i == currentIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.tag = 100;
        [btn addSubview:lbl];
        
        [btn addTarget:self 
                action:@selector(prioritySegmentTapped:) 
      forControlEvents:UIControlEventTouchUpInside];
        
        [container addSubview:btn];
    }
    
    return y + segmentHeight + kPillSpacing;
}

- (CGFloat)addLanguageSegment:(CGFloat)y width:(CGFloat)w padding:(CGFloat)p {
    CGFloat segmentHeight = 44;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(p, y, w, segmentHeight)];
    container.backgroundColor = [self pillColor];
    container.layer.cornerRadius = segmentHeight / 2;
    container.layer.borderWidth = 1.0;
    container.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    container.tag = 77004; // Unique tag for language segment
    [self.contentContainer addSubview:container];
    
    NSArray *titles = @[@"English", @"Português"];
    CGFloat buttonWidth = (w - 8) / 2.0;
    
    // Load saved language preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentIndex = [defaults integerForKey:@"ModMenuLanguage"];
    if (currentIndex < 0 || currentIndex > 1) currentIndex = 0;
    self.currentLanguage = currentIndex;
    

    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(
        4 + (buttonWidth * currentIndex), 4, buttonWidth, segmentHeight - 8)];
    indicator.backgroundColor = [self accentColor];
    indicator.layer.cornerRadius = (segmentHeight - 8) / 2;
    indicator.tag = 9004;
    indicator.layer.shadowColor = [self glowColor].CGColor;
    indicator.layer.shadowRadius = 8;
    indicator.layer.shadowOpacity = 0.6;
    indicator.layer.shadowOffset = CGSizeZero;
    [container addSubview:indicator];
    
    // Create 2 buttons
    for (int i = 0; i < 2; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(
            4 + (buttonWidth * i), 4, buttonWidth, segmentHeight - 8)];
        btn.tag = 41000 + i;
        btn.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:btn.bounds];
        lbl.text = titles[i];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:13 
            weight:(i == currentIndex) ? UIFontWeightBold : UIFontWeightSemibold];
        lbl.textColor = (i == currentIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.tag = 100;
        [btn addSubview:lbl];
        
        [btn addTarget:self 
                action:@selector(languageSegmentTapped:) 
      forControlEvents:UIControlEventTouchUpInside];
        
        [container addSubview:btn];
    }
    
    return y + segmentHeight + kPillSpacing;
}

- (CGFloat)addColorPickerSegment:(NSString *)title 
                        colorType:(int)colorType 
                              atY:(CGFloat)y 
                            width:(CGFloat)w 
                          padding:(CGFloat)p {
    // Add label
    y = [self addSectionLabel:title atY:y width:w padding:p];
    
    CGFloat segmentHeight = 44;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(p, y, w, segmentHeight)];
    container.backgroundColor = [self pillColor];
    container.layer.cornerRadius = segmentHeight / 2;
    container.layer.borderWidth = 1.0;
    container.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    container.tag = 77010 + colorType; // Unique tag per color type
    [self.contentContainer addSubview:container];
    
    NSArray *colorNames = @[@"Branco", @"Vermelho", @"Azul", @"Verde", @"Rosa"];
    CGFloat buttonWidth = (w - 8) / 5.0;
    
    // Get current color index based on colorType
    int currentIndex = 0;
    switch (colorType) {
        case 0: currentIndex = ESPLineColor; break;
        case 1: currentIndex = ESPBoxColor; break;
        case 2: currentIndex = ESPSkeletonColor; break;
        case 3: currentIndex = ESPNameColor; break;
        case 4: currentIndex = AimbotFOVColor; break;
        default: currentIndex = 0; break;
    }
    if (currentIndex < 0 || currentIndex > 4) currentIndex = 0;
    
    // Indicator at correct position
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(
        4 + (buttonWidth * currentIndex), 4, buttonWidth, segmentHeight - 8)];
    indicator.backgroundColor = [self accentColor];
    indicator.layer.cornerRadius = (segmentHeight - 8) / 2;
    indicator.tag = 9010 + colorType;
    indicator.layer.shadowColor = [self glowColor].CGColor;
    indicator.layer.shadowRadius = 8;
    indicator.layer.shadowOpacity = 0.6;
    indicator.layer.shadowOffset = CGSizeZero;
    [container addSubview:indicator];
    
    // Create 5 buttons for colors
    for (int i = 0; i < 5; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(
            4 + (buttonWidth * i), 4, buttonWidth, segmentHeight - 8)];
        btn.tag = 40000 + (colorType * 100) + i; // Unique tag per color type and index
        btn.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:btn.bounds];
        lbl.text = colorNames[i];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:11 
            weight:(i == currentIndex) ? UIFontWeightBold : UIFontWeightSemibold];
        lbl.textColor = (i == currentIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.tag = 100;
        [btn addSubview:lbl];
        
        [btn addTarget:self 
                action:@selector(colorSegmentTapped:) 
      forControlEvents:UIControlEventTouchUpInside];
        
        [container addSubview:btn];
    }
    
    return y + segmentHeight + kPillSpacing;
}

- (void)colorSegmentTapped:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSInteger colorType = (tag - 40000) / 100;
    NSInteger colorIndex = (tag - 40000) % 100;
    
    if (colorIndex < 0 || colorIndex > 4) return;
    
    // Update the appropriate color variable
    switch (colorType) {
        case 0: ESPLineColor = (int)colorIndex; break;
        case 1: ESPBoxColor = (int)colorIndex; break;
        case 2: ESPSkeletonColor = (int)colorIndex; break;
        case 3: ESPNameColor = (int)colorIndex; break;
        case 4: AimbotFOVColor = (int)colorIndex; break;
        default: break;
    }
    
    // Find container
    UIView *container = [self.contentContainer viewWithTag:77010 + colorType];
    if (!container) return;
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    // Move indicator
    UIView *indicator = [container viewWithTag:9010 + colorType];
    CGFloat buttonWidth = (container.frame.size.width - 8) / 5.0;
    
    [UIView animateWithDuration:0.3 
                          delay:0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:1.0 
                        options:0 
                     animations:^{
        indicator.frame = CGRectMake(4 + (buttonWidth * colorIndex), 4, 
                                    buttonWidth, container.frame.size.height - 8);
    } completion:nil];
    
    // Update labels
    for (int i = 0; i < 5; i++) {
        UIButton *btn = [container viewWithTag:40000 + (colorType * 100) + i];
        UILabel *lbl = [btn viewWithTag:100];
        lbl.textColor = (i == colorIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.font = [UIFont systemFontOfSize:11 
            weight:(i == colorIndex) ? UIFontWeightBold : UIFontWeightSemibold];
    }
}

- (void)languageSegmentTapped:(UIButton *)sender {
    NSInteger newIndex = sender.tag - 41000;
    if (newIndex < 0 || newIndex > 1) return;
    
    self.currentLanguage = newIndex;
    
    // Save language preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:newIndex forKey:@"ModMenuLanguage"];
    [defaults synchronize];
    
    // Find container
    UIView *container = [self.contentContainer viewWithTag:77004];
    if (!container) return;
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    // Move indicator
    UIView *indicator = [container viewWithTag:9004];
    CGFloat buttonWidth = (container.frame.size.width - 8) / 2.0;
    
    [UIView animateWithDuration:0.3 
                          delay:0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:1.0 
                        options:0 
                     animations:^{
        indicator.frame = CGRectMake(4 + (buttonWidth * newIndex), 4, 
                                     buttonWidth, container.frame.size.height - 8);
    } completion:nil];
    
    // Update labels
    for (int i = 0; i < 2; i++) {
        UIButton *btn = [container viewWithTag:41000 + i];
        UILabel *lbl = [btn viewWithTag:100];
        lbl.textColor = (i == newIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.font = [UIFont systemFontOfSize:13 
            weight:(i == newIndex) ? UIFontWeightBold : UIFontWeightSemibold];
    }
    
    // Reload current tab content to update all text to new language
    [self updateHeaderForTab:self.currentTab];
    [self loadTabContent:self.currentTab];
}

- (void)prioritySegmentTapped:(UIButton *)sender {
    NSInteger newIndex = sender.tag - 31000;
    if (newIndex < 0 || newIndex > 2) return;
    
    // WRITE DIRECTLY TO VARS
    Vars.TargetPriority = (int)newIndex;
    
    // Find container
    UIView *container = [self.contentContainer viewWithTag:77003];
    if (!container) return;
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    // Move indicator
    UIView *indicator = [container viewWithTag:9003];
    CGFloat buttonWidth = (container.frame.size.width - 8) / 3.0;
    
    [UIView animateWithDuration:0.3 
                          delay:0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:1.0 
                        options:0 
                     animations:^{
        indicator.frame = CGRectMake(4 + (buttonWidth * newIndex), 4, 
                                     buttonWidth, container.frame.size.height - 8);
    } completion:nil];
    
    // Update labels
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [container viewWithTag:31000 + i];
        UILabel *lbl = [btn viewWithTag:100];
        lbl.textColor = (i == newIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.font = [UIFont systemFontOfSize:12 
            weight:(i == newIndex) ? UIFontWeightBold : UIFontWeightSemibold];
    }
}

- (CGFloat)addMenuColorPickerSegment:(NSString *)title 
                              atY:(CGFloat)y 
                            width:(CGFloat)w 
                          padding:(CGFloat)p {
    CGFloat segmentHeight = 44;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(p, y, w, segmentHeight)];
    container.backgroundColor = [self pillColor];
    container.layer.cornerRadius = segmentHeight / 2;
    container.layer.borderWidth = 1.0;
    container.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    container.tag = 77020; // Unique tag for menu color
    [self.contentContainer addSubview:container];
    
    NSArray *colorNames = @[@"Vermelho", @"Azul", @"Verde", @"Rosa"];
    CGFloat buttonWidth = (w - 8) / 4.0;
    
    // Get current menu color theme
    int currentIndex = MenuColorTheme;
    if (currentIndex < 0 || currentIndex > 3) currentIndex = 0;
    
    // Indicator at correct position
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(
        4 + (buttonWidth * currentIndex), 4, buttonWidth, segmentHeight - 8)];
    indicator.backgroundColor = [self accentColor];
    indicator.layer.cornerRadius = (segmentHeight - 8) / 2;
    indicator.tag = 9020;
    indicator.layer.shadowColor = [self glowColor].CGColor;
    indicator.layer.shadowRadius = 8;
    indicator.layer.shadowOpacity = 0.6;
    indicator.layer.shadowOffset = CGSizeZero;
    [container addSubview:indicator];
    
    // Create 4 buttons for colors
    for (int i = 0; i < 4; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(
            4 + (buttonWidth * i), 4, buttonWidth, segmentHeight - 8)];
        btn.tag = 50000 + i; // Unique tag for menu color
        btn.backgroundColor = [UIColor clearColor];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:btn.bounds];
        lbl.text = colorNames[i];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:12 
            weight:(i == currentIndex) ? UIFontWeightBold : UIFontWeightSemibold];
        lbl.textColor = (i == currentIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.tag = 100;
        [btn addSubview:lbl];
        
        [btn addTarget:self 
                action:@selector(menuColorSegmentTapped:) 
      forControlEvents:UIControlEventTouchUpInside];
        
        [container addSubview:btn];
    }
    
    return y + segmentHeight + kPillSpacing;
}

- (void)menuColorSegmentTapped:(UIButton *)sender {
    NSInteger colorIndex = sender.tag - 50000;
    
    if (colorIndex < 0 || colorIndex > 3) return;
    
    // Update menu color theme
    MenuColorTheme = (int)colorIndex;
    
    // Find container
    UIView *container = [self.contentContainer viewWithTag:77020];
    if (!container) return;
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleMedium];
    [fb impactOccurred];
    
    // Move indicator
    UIView *indicator = [container viewWithTag:9020];
    CGFloat buttonWidth = (container.frame.size.width - 8) / 4.0;
    
    [UIView animateWithDuration:0.3 
                          delay:0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:1.0 
                        options:0 
                     animations:^{
        indicator.frame = CGRectMake(4 + (buttonWidth * colorIndex), 4, 
                                    buttonWidth, container.frame.size.height - 8);
        indicator.backgroundColor = [self accentColor];
    } completion:nil];
    
    // Update labels
    for (int i = 0; i < 4; i++) {
        UIButton *btn = [container viewWithTag:50000 + i];
        UILabel *lbl = [btn viewWithTag:100];
        lbl.textColor = (i == colorIndex) ? [UIColor whiteColor] : [self textColor];
        lbl.font = [UIFont systemFontOfSize:12 
            weight:(i == colorIndex) ? UIFontWeightBold : UIFontWeightSemibold];
    }
    
    // Update all UI colors
    [self updateAllColors];
}

- (void)toggleGlow:(UISwitch *)s {
    Vars.Glow = s.on;
}


- (CGFloat)createProfileContent:(CGFloat)startY 
                          width:(CGFloat)w 
                        padding:(CGFloat)p {
    CGFloat y = startY;
    BOOL isPT = (self.currentLanguage == 1);
    
    // FPS
    UILabel *fpsLabel = nil;
    y = [self addProfileRow:isPT ? @"FPS" : @"FPS" 
                 valueLabel:&fpsLabel 
                      value:[NSString stringWithFormat:@"%.0f", self.currentFPS] 
                      color:[UIColor systemGreenColor] 
                        atY:y width:w padding:p];
    _fpsLabel = fpsLabel;
    
    // Time
    UILabel *timeLabel = nil;
    y = [self addProfileRow:isPT ? @"Tempo" : @"Time" 
                 valueLabel:&timeLabel 
                      value:@"00:00:00" 
                      color:[self accentColor] 
                        atY:y width:w padding:p];
    _timeLabel = timeLabel;
    
    // Device
    y = [self addProfileTextRow:isPT ? @"Dispositivo" : @"Device" 
                          value:[[UIDevice currentDevice] model] 
                            atY:y width:w padding:p];
    
    // iOS Version
    y = [self addProfileTextRow:isPT ? @"iOS" : @"iOS" 
                          value:[[UIDevice currentDevice] systemVersion] 
                            atY:y width:w padding:p];
    
    // Device Name
    y = [self addProfileTextRow:isPT ? @"Nome" : @"Name" 
                          value:[[UIDevice currentDevice] name] 
                            atY:y width:w padding:p];
    
    // App Version with Support Check
    //NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
   // if (!appVersion || appVersion.length == 0) {
       // appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
   // }
   // if (!appVersion || appVersion.length == 0) {
    //    appVersion = isPT ? @"Desconhecido" : @"Unknown";
   // }
    
    // Check if version is supported (support till 1.118.1, so <= 1.118.1 is supported)
    //BOOL isSupported = [self isVersionSupported:appVersion];
   // NSString *versionDisplay = isSupported ? appVersion : [NSString stringWithFormat:@"%@ (%@)", appVersion, isPT ? @"Não suportado" : @"No supported"];
    //UIColor *versionColor = isSupported ? [UIColor systemGreenColor] : [UIColor systemRedColor];
   // y = [self addProfileTextRowColored:isPT ? @"Versão" : @"Version" 
                                // value:versionDisplay 
                                 //color:versionColor 
                                   //atY:y width:w padding:p];
    
    // Menu Color Theme Selection
    y = [self addSectionLabel:isPT ? @"Tema do Menu" : @"Menu Theme" 
                          atY:y width:w padding:p];
    
    y = [self addMenuColorPickerSegment:isPT ? @"Cor do Menu" : @"Menu Color" 
                              atY:y width:w padding:p];
    
    // License Manager Info (optional)
    id license = [self getLicenseManager];
    
    if (license) {
        @try {
            // License Key removed
            
            // Device UDID (copyable)
            NSString *udidDisplay = isPT ? @"Desconhecido" : @"Unknown";
            if ([license respondsToSelector:@selector(deviceUDID)]) {
                NSString *udid = [license performSelector:@selector(deviceUDID)];
                udidDisplay = udid ?: (isPT ? @"Desconhecido" : @"Unknown");
            }
            y = [self addProfileTextRowCopyable:isPT ? @"UDID" : @"UDID" 
                                         value:udidDisplay 
                                         color:[self textColor] 
                                           atY:y width:w padding:p];
            
            // Authorization Status
            BOOL isAuthorized = NO;
            if ([license respondsToSelector:@selector(isAuthorized)]) {
                isAuthorized = ((BOOL (*)(id, SEL))objc_msgSend)(license, @selector(isAuthorized));
            }
            
            NSString *authStatus = isAuthorized ? (isPT ? @"Autorizado" : @"Authorized") : (isPT ? @"Não Autorizado" : @"Not Authorized");
            UIColor *authColor = isAuthorized ? [UIColor systemGreenColor] : [UIColor systemRedColor];
            y = [self addProfileTextRowColored:isPT ? @"Status" : @"Status" 
                                         value:authStatus 
                                         color:authColor 
                                           atY:y width:w padding:p];
            
            // Remaining Time
            NSInteger remainingTime = 0;
            if ([license respondsToSelector:@selector(remainingTime)]) {
                remainingTime = ((NSInteger (*)(id, SEL))objc_msgSend)(license, @selector(remainingTime));
            }
            
            if (isAuthorized && remainingTime > 0) {
                NSString *timeDisplay = @"N/A";
                if ([license respondsToSelector:@selector(formattedRemainingTime)]) {
                    NSString *formatted = [license performSelector:@selector(formattedRemainingTime)];
                    timeDisplay = formatted ?: @"N/A";
                }
                y = [self addProfileTextRow:isPT ? @"Tempo Restante" : @"Remaining Time" 
                                     value:timeDisplay 
                                       atY:y width:w padding:p];
            }
        } @catch (NSException *exception) {
            // Silently fail if LicenseManager methods don't exist
        }
    }
    
    // Language selector
    y = [self addSectionLabel:isPT ? @"Idioma" : @"Language" 
                          atY:y width:w padding:p];
    y = [self addLanguageSegment:y width:w padding:p];
    
    return y;
}

- (BOOL)isVersionSupported:(NSString *)version {
    if (!version || version.length == 0) {
        return NO;
    }
    
    // Support till 1.118.1, so versions <= 1.118.1 are supported
    // Parse version string (format: X.Y.Z or X.Y.Z.W)
    NSArray *components = [version componentsSeparatedByString:@"."];
    if (components.count < 2) {
        return NO;
    }
    
    // Get major and minor version
    NSInteger major = [components[0] integerValue];
    NSInteger minor = [components[1] integerValue];
    NSInteger patch = components.count > 2 ? [components[2] integerValue] : 0;
    
    // Support till 1.118.1 means:
    // - Major version must be 1
    // - Minor version must be <= 118
    // - If minor == 118, patch must be <= 1
    if (major != 1) {
        return NO; // Only version 1.x.x is supported
    }
    
    if (minor < 118) {
        return YES; // All versions 1.0.x to 1.117.x are supported
    }
    
    if (minor == 118) {
        return patch <= 1; // Only 1.118.0 and 1.118.1 are supported
    }
    
    return NO; // 1.119.x and above are not supported
}

- (CGFloat)addProfileRow:(NSString *)title 
               valueLabel:(UILabel **)labelPtr 
                    value:(NSString *)value 
                    color:(UIColor *)color 
                      atY:(CGFloat)y 
                    width:(CGFloat)w 
                  padding:(CGFloat)p {
    UILabel *tL = [[UILabel alloc] initWithFrame:CGRectMake(p, y, 80, 24)];
    tL.text = title;
    tL.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    tL.textColor = [self secondaryTextColor];
    [self.contentContainer addSubview:tL];
    
    UILabel *vL = [[UILabel alloc] initWithFrame:CGRectMake(90, y, w - 90, 24)];
    vL.text = value;
    vL.font = [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightBold];
    vL.textColor = color;
    [self.contentContainer addSubview:vL];
    *labelPtr = vL;
    
    return y + 32;
}

- (CGFloat)addProfileTextRow:(NSString *)title 
                       value:(NSString *)value 
                         atY:(CGFloat)y 
                       width:(CGFloat)w 
                     padding:(CGFloat)p {
    UILabel *tL = [[UILabel alloc] initWithFrame:CGRectMake(p, y, 80, 22)];
    tL.text = title;
    tL.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    tL.textColor = [self secondaryTextColor];
    [self.contentContainer addSubview:tL];
    
    UILabel *vL = [[UILabel alloc] initWithFrame:CGRectMake(90, y, w - 90, 22)];
    vL.text = value;
    vL.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    vL.textColor = [self textColor];
    [self.contentContainer addSubview:vL];
    
    return y + 30;
}

- (CGFloat)addProfileTextRowColored:(NSString *)title 
                              value:(NSString *)value 
                              color:(UIColor *)color 
                                atY:(CGFloat)y 
                              width:(CGFloat)w 
                            padding:(CGFloat)p {
    UILabel *tL = [[UILabel alloc] initWithFrame:CGRectMake(p, y, 80, 22)];
    tL.text = title;
    tL.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    tL.textColor = [self secondaryTextColor];
    [self.contentContainer addSubview:tL];
    
    UILabel *vL = [[UILabel alloc] initWithFrame:CGRectMake(90, y, w - 90, 22)];
    vL.text = value;
    vL.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    vL.textColor = color;
    [self.contentContainer addSubview:vL];
    
    return y + 30;
}

- (CGFloat)addProfileTextRowCopyable:(NSString *)title 
                              value:(NSString *)value 
                              color:(UIColor *)color 
                                atY:(CGFloat)y 
                              width:(CGFloat)w 
                            padding:(CGFloat)p {
    UILabel *tL = [[UILabel alloc] initWithFrame:CGRectMake(p, y, 80, 22)];
    tL.text = title;
    tL.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    tL.textColor = [self secondaryTextColor];
    [self.contentContainer addSubview:tL];
    
    // Create a button for the value so it's tappable
    UIButton *copyButton = [[UIButton alloc] initWithFrame:CGRectMake(90, y, w - 90, 22)];
    copyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [copyButton setTitle:value forState:UIControlStateNormal];
    [copyButton setTitleColor:color forState:UIControlStateNormal];
    copyButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    copyButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    // Store the value to copy in the button's tag or associated object
    objc_setAssociatedObject(copyButton, "copyValue", value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [copyButton addTarget:self action:@selector(copyProfileValue:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentContainer addSubview:copyButton];
    
    // Add copy icon
    UIImageView *copyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(w - 30, y + 3, 16, 16)];
    copyIcon.image = [[UIImage systemImageNamed:@"doc.on.doc"] 
        imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration 
            configurationWithPointSize:12 weight:UIImageSymbolWeightMedium]];
    copyIcon.tintColor = [self secondaryTextColor];
    [self.contentContainer addSubview:copyIcon];
    
    return y + 30;
}

- (void)copyProfileValue:(UIButton *)sender {
    NSString *valueToCopy = objc_getAssociatedObject(sender, "copyValue");
    if (!valueToCopy || valueToCopy.length == 0) {
        return;
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = valueToCopy;
    
    // Show feedback
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    // Visual feedback - briefly highlight the button
    UIColor *originalColor = sender.titleLabel.textColor;
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTitleColor:[self accentColor] forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.3 options:0 animations:^{
            [sender setTitleColor:originalColor forState:UIControlStateNormal];
        } completion:nil];
    }];
}






#pragma mark - Pill UI Components

- (CGFloat)addFeaturePill:(NSString *)title 
                      key:(NSString *)key 
                    value:(BOOL)value 
                 selector:(SEL)selector 
                      atY:(CGFloat)y 
                    width:(CGFloat)w 
                  padding:(CGFloat)p {
    CGFloat h = kPillHeight;
    UIView *pill = [[UIView alloc] initWithFrame:CGRectMake(p, y, w, h)];
    pill.backgroundColor = [self pillColor];
    pill.layer.cornerRadius = h / 2;
    pill.tag = [key hash] + 1000;
    
    pill.layer.borderWidth = 1.0;
    pill.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    
    CALayer *innerShadow = [CALayer layer];
    innerShadow.frame = pill.bounds;
    innerShadow.cornerRadius = h / 2;
    innerShadow.shadowColor = isDarkMode ? 
        [UIColor colorWithWhite:0.0 alpha:0.3].CGColor : 
        [UIColor colorWithWhite:0.0 alpha:0.15].CGColor;
    innerShadow.shadowOffset = CGSizeMake(0, 1);
    innerShadow.shadowOpacity = 1.0;
    innerShadow.shadowRadius = 2;
    [pill.layer addSublayer:innerShadow];
    
    if (value) {
        pill.layer.shadowColor = [self glowColor].CGColor;
        pill.layer.shadowRadius = 10;
        pill.layer.shadowOpacity = 1.0;
        pill.layer.shadowOffset = CGSizeZero;
        
        CAGradientLayer *shimmer = [CAGradientLayer layer];
        shimmer.frame = pill.bounds;
        shimmer.colors = @[
            (id)[[UIColor colorWithWhite:1.0 alpha:0.0] CGColor],
            (id)[[UIColor colorWithWhite:1.0 alpha:0.15] CGColor],
            (id)[[UIColor colorWithWhite:1.0 alpha:0.0] CGColor]
        ];
        shimmer.startPoint = CGPointMake(0, 0.5);
        shimmer.endPoint = CGPointMake(1, 0.5);
        shimmer.locations = @[@0.0, @0.5, @1.0];
        shimmer.cornerRadius = h / 2;
        [pill.layer addSublayer:shimmer];
    }
    
    [self.contentContainer addSubview:pill];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, w - 75, h)];
    lbl.text = title;
    lbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    lbl.textColor = [self textColor];
    [pill addSubview:lbl];
    
    UIButton *cb = [[UIButton alloc] initWithFrame:CGRectMake(
        w - 48, (h - 26) / 2, 26, 26)];
    cb.backgroundColor = value ? [self accentColor] : [self checkboxOffColor];
    cb.layer.cornerRadius = 13;
    
    cb.layer.shadowColor = [UIColor blackColor].CGColor;
    cb.layer.shadowOpacity = 0.2;
    cb.layer.shadowRadius = 2;
    cb.layer.shadowOffset = CGSizeMake(0, 1);
    
    if (value) {
        UIImageView *check = [[UIImageView alloc] initWithFrame:CGRectMake(
            7, 7, 12, 12)];
        check.image = [[UIImage systemImageNamed:@"checkmark"] 
            imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration 
                configurationWithPointSize:11 weight:UIImageSymbolWeightBold]];
        check.tintColor = [UIColor whiteColor];
        check.tag = 500;
        [cb addSubview:check];
    }
    
    cb.tag = [key hash];
    if (selector) {
        [cb addTarget:self 
               action:@selector(checkboxTapped:) 
     forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(cb, "selector", 
                                 NSStringFromSelector(selector), 
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(cb, "key", key, 
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(cb, "pill", pill, 
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [pill addSubview:cb];
    allCheckboxes[key] = cb;
    self.checkboxStates[key] = @(value);
    
    return y + h + kPillSpacing;
}

- (CGFloat)addFeaturePillWithDescription:(NSString *)title 
                                    key:(NSString *)key 
                                  value:(BOOL)value 
                               selector:(SEL)selector 
                            description:(NSString *)description 
                                   atY:(CGFloat)y 
                                 width:(CGFloat)w 
                               padding:(CGFloat)p {
    // Add the pill first
    CGFloat yPos = [self addFeaturePill:title 
                                    key:key 
                                  value:value 
                               selector:selector 
                                    atY:y 
                                  width:w 
                                padding:p];
    
    // Add description text below the pill
    if (description && description.length > 0) {
        // Position description below the pill (pill ends at yPos - kPillSpacing, so start description there)
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(
            p + 18, yPos - kPillSpacing + 2, w - 36, 18)];
        descLabel.text = description;
        descLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
        descLabel.textColor = [self secondaryTextColor];
        descLabel.numberOfLines = 1;
        descLabel.alpha = 0.7;
        [self.contentContainer addSubview:descLabel];
        
        // Return position accounting for description height (18px) plus small spacing
        return yPos + 18;
    }
    
    return yPos;
}

- (CGFloat)addSectionLabel:(NSString *)title 
                       atY:(CGFloat)y 
                     width:(CGFloat)w 
                   padding:(CGFloat)p {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(p, y + 6, w, 20)];
    lbl.text = title;
    lbl.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    lbl.textColor = [self secondaryTextColor];
    [self.contentContainer addSubview:lbl];
    return y + 30;
}

- (CGFloat)addSegmentControl:(NSArray *)items 
               selectedIndex:(NSInteger)index 
                    selector:(SEL)selector 
                         atY:(CGFloat)y 
                       width:(CGFloat)w 
                     padding:(CGFloat)p {
    
    // Create container view for custom segment control
    CGFloat segmentHeight = 44;
    UIView *segmentContainer = [[UIView alloc] initWithFrame:CGRectMake(
        p, y, w, segmentHeight)];
    segmentContainer.backgroundColor = [self pillColor];
    segmentContainer.layer.cornerRadius = segmentHeight / 2;
    
    // Add subtle border
    segmentContainer.layer.borderWidth = 1.0;
    segmentContainer.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithWhite:1.0 alpha:0.08] CGColor] : 
        [[UIColor colorWithWhite:0.0 alpha:0.05] CGColor];
    
    [self.contentContainer addSubview:segmentContainer];
    
    CGFloat totalButtonWidth = w - 8; // Total available width (minus padding)
    CGFloat buttonWidth = totalButtonWidth / items.count; // Equal width for each button
    
    // Create sliding indicator background FIRST
    UIView *selectedIndicator = [[UIView alloc] initWithFrame:CGRectMake(
        4 + (buttonWidth * index), 
        4, 
        buttonWidth, 
        segmentHeight - 8)];
    selectedIndicator.backgroundColor = [self accentColor];
    selectedIndicator.layer.cornerRadius = (segmentHeight - 8) / 2;
    selectedIndicator.tag = 9000;
    
    // Add glow to selected indicator
    selectedIndicator.layer.shadowColor = [self glowColor].CGColor;
    selectedIndicator.layer.shadowRadius = 8;
    selectedIndicator.layer.shadowOpacity = 0.6;
    selectedIndicator.layer.shadowOffset = CGSizeZero;
    
    [segmentContainer insertSubview:selectedIndicator atIndex:0]; // Insert at back
    
    // Create buttons for each segment
    for (int i = 0; i < items.count; i++) {
        CGFloat xPos = 4 + (buttonWidth * i);
        
        UIButton *segmentButton = [[UIButton alloc] initWithFrame:CGRectMake(
            xPos, 4, buttonWidth, segmentHeight - 8)];
        segmentButton.tag = 10000 + i;
        segmentButton.backgroundColor = [UIColor clearColor];
        
        // Create label for button
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
            0, 0, buttonWidth, segmentHeight - 8)];
        titleLabel.text = items[i];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:13 
            weight:(i == index) ? UIFontWeightBold : UIFontWeightSemibold];
        titleLabel.textColor = (i == index) ? [UIColor whiteColor] : [self textColor];
        titleLabel.tag = 100;
        titleLabel.userInteractionEnabled = NO;
        [segmentButton addSubview:titleLabel];
        
        // Add tap action
        [segmentButton addTarget:self 
                          action:@selector(customSegmentTapped:) 
                forControlEvents:UIControlEventTouchUpInside];
        
        // Store metadata
        objc_setAssociatedObject(segmentButton, "selector", 
                                 NSStringFromSelector(selector), 
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(segmentButton, "container", 
                                 segmentContainer, 
                                 OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(segmentButton, "segmentIndex", 
                                 @(i), 
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [segmentContainer addSubview:segmentButton];
    }
    
    // Store metadata in container
    objc_setAssociatedObject(segmentContainer, "currentIndex", 
                             @(index), 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(segmentContainer, "itemCount", 
                             @(items.count), 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(segmentContainer, "buttonWidth", 
                             @(buttonWidth), 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return y + segmentHeight + kPillSpacing;
}

- (void)customSegmentTapped:(UIButton *)sender {
    UIView *container = objc_getAssociatedObject(sender, "container");
    NSString *selectorString = objc_getAssociatedObject(sender, "selector");
    NSNumber *segmentIndexNum = objc_getAssociatedObject(sender, "segmentIndex");
    
    NSNumber *currentIndexNum = objc_getAssociatedObject(container, "currentIndex");
    NSNumber *buttonWidthNum = objc_getAssociatedObject(container, "buttonWidth");
    
    NSInteger currentIndex = [currentIndexNum integerValue];
    NSInteger newIndex = [segmentIndexNum integerValue];
    CGFloat buttonWidth = [buttonWidthNum floatValue];
    
    // Don't animate if same button
    if (newIndex == currentIndex) return;
    
    // Haptic feedback
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    // Find the sliding indicator
    UIView *indicator = [container viewWithTag:9000];
    if (!indicator) return;
    
    // Calculate exact new position based on button index
    CGFloat newX = 4 + (buttonWidth * newIndex);
    
    // Animate indicator slide with bounce
    [UIView animateWithDuration:0.4 
                          delay:0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:0.8 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
        indicator.frame = CGRectMake(newX, 4, buttonWidth, 
                                     container.frame.size.height - 8);
    } completion:nil];
    
    // Update all button text colors
    for (UIView *subview in container.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && subview.tag >= 10000) {
            UIButton *btn = (UIButton *)subview;
            NSNumber *btnIndexNum = objc_getAssociatedObject(btn, "segmentIndex");
            NSInteger btnIndex = [btnIndexNum integerValue];
            UILabel *label = [btn viewWithTag:100];
            
            if (label) {
                [UIView transitionWithView:label 
                                  duration:0.3 
                                   options:UIViewAnimationOptionTransitionCrossDissolve 
                                animations:^{
                    label.textColor = (btnIndex == newIndex) ? 
                        [UIColor whiteColor] : [self textColor];
                    label.font = [UIFont systemFontOfSize:13 
                        weight:(btnIndex == newIndex) ? 
                            UIFontWeightBold : UIFontWeightSemibold];
                } completion:nil];
            }
        }
    }
    
    // Update stored index
    objc_setAssociatedObject(container, "currentIndex", @(newIndex), 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Call the actual selector
    if (selectorString) {
        SEL sel = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:sel]) {
            // Create fake segment control for compatibility
            UISegmentedControl *fakeSegment = [[UISegmentedControl alloc] init];
            fakeSegment.selectedSegmentIndex = newIndex;
            
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:sel withObject:fakeSegment];
            #pragma clang diagnostic pop
        }
    }
}

- (CGFloat)addButtonPill:(NSString *)title 
                    isOn:(BOOL)isOn 
                selector:(SEL)selector 
                     atY:(CGFloat)y 
                   width:(CGFloat)w 
                 padding:(CGFloat)p {
    CGFloat h = 38;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(p, y, w, h)];
    btn.backgroundColor = isOn ? [self accentColor] : [self pillColor];
    btn.layer.cornerRadius = h / 2;
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:isOn ? [UIColor whiteColor] : [self textColor] 
              forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    
    if (isOn) {
        btn.layer.shadowColor = [self glowColor].CGColor;
        btn.layer.shadowRadius = 8;
        btn.layer.shadowOpacity = 0.8;
        btn.layer.shadowOffset = CGSizeZero;
    }
    
    [btn addTarget:self 
            action:selector 
  forControlEvents:UIControlEventTouchUpInside];
    [self.contentContainer addSubview:btn];
    
    return y + h + kPillSpacing;
}

- (CGFloat)addSliderPill:(NSString *)title 
                   value:(CGFloat)value 
                     min:(CGFloat)min 
                     max:(CGFloat)max 
                selector:(SEL)selector 
                     atY:(CGFloat)y 
                   width:(CGFloat)w 
                 padding:(CGFloat)p {
    UIView *pill = [[UIView alloc] initWithFrame:CGRectMake(p, y, w, 70)];
    pill.backgroundColor = [self pillColor];
    pill.layer.cornerRadius = 35;
    [self.contentContainer addSubview:pill];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, w - 80, 18)];
    lbl.text = title;
    lbl.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    lbl.textColor = [self textColor];
    [pill addSubview:lbl];
    
    UILabel *valL = [[UILabel alloc] initWithFrame:CGRectMake(
        w - 60, 10, 44, 18)];
    // Format based on slider range - show decimals for fly height
    if (max <= 50.0f && min == 0.0f) {
        valL.text = [NSString stringWithFormat:@"%.1f", value];
    } else {
        valL.text = [NSString stringWithFormat:@"%.0f", value];
    }
    valL.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    valL.textColor = [self accentColor];
    valL.textAlignment = NSTextAlignmentRight;
    valL.tag = 600;
    [pill addSubview:valL];
    
    UISlider *sl = [[UISlider alloc] initWithFrame:CGRectMake(
        16, 36, w - 32, 24)];
    sl.minimumValue = min;
    sl.maximumValue = max;
    sl.value = value;
    sl.minimumTrackTintColor = [self accentColor];
    sl.maximumTrackTintColor = isDarkMode ? 
        [UIColor colorWithWhite:0.3 alpha:1] : 
        [UIColor colorWithWhite:0.65 alpha:1];
    [sl addTarget:self 
           action:selector 
 forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(sl, "valueLabel", valL, 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [pill addSubview:sl];
    
    self.slider = sl;
    return y + 78;
}

#pragma mark - Checkbox Handler

- (void)checkboxTapped:(UIButton *)sender {
    if (!sender) return;
    
    NSString *key = objc_getAssociatedObject(sender, "key");
    NSString *selectorString = objc_getAssociatedObject(sender, "selector");
    UIView *pill = objc_getAssociatedObject(sender, "pill");
    
    if (!key || !self.checkboxStates) return;
    
    BOOL currentState = [self.checkboxStates[key] boolValue];
    BOOL newState = !currentState;
    self.checkboxStates[key] = @(newState);
    
    [UIView animateWithDuration:0.2 
                          delay:0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:0.8 
                        options:0 
                     animations:^{
        if (sender) {
            sender.backgroundColor = newState ? 
                [self accentColor] : [self checkboxOffColor];
            sender.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }
        if (pill && pill.layer) {
            if (newState) {
                pill.layer.shadowColor = [self glowColor].CGColor;
                pill.layer.shadowRadius = 10;
                pill.layer.shadowOpacity = 1.0;
                pill.layer.shadowOffset = CGSizeZero;
            } else {
                pill.layer.shadowOpacity = 0.0;
            }
        }
    } completion:^(BOOL f) {
        [UIView animateWithDuration:0.15 
                              delay:0 
             usingSpringWithDamping:0.6 
              initialSpringVelocity:0.5 
                            options:0 
                         animations:^{ 
            sender.transform = CGAffineTransformIdentity; 
        } completion:nil];
    }];
    
    UIImageView *check = [sender viewWithTag:500];
    if (newState && !check) {
        check = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 16, 16)];
        check.image = [[UIImage systemImageNamed:@"checkmark"] 
            imageByApplyingSymbolConfiguration:[UIImageSymbolConfiguration 
                configurationWithPointSize:11 weight:UIImageSymbolWeightBold]];
        check.tintColor = [UIColor whiteColor];
        check.tag = 500;
        check.alpha = 0;
        check.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [sender addSubview:check];
        [UIView animateWithDuration:0.2 
                              delay:0.05 
             usingSpringWithDamping:0.7 
              initialSpringVelocity:1.0 
                            options:0 
                         animations:^{ 
            check.alpha = 1;
            check.transform = CGAffineTransformIdentity;
        } completion:nil];
    } else if (!newState && check) {
        [UIView animateWithDuration:0.15 animations:^{ 
            check.alpha = 0;
            check.transform = CGAffineTransformMakeScale(0.5, 0.5);
        } completion:^(BOOL f) { 
            [check removeFromSuperview]; 
        }];
    }
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleLight];
    [fb impactOccurred];
    
    if (selectorString) {
        SEL sel = NSSelectorFromString(selectorString);
        if ([self respondsToSelector:sel]) {
            UISwitch *fs = [[UISwitch alloc] init];
            fs.on = newState;
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:sel withObject:fs];
            #pragma clang diagnostic pop
        }
    }
}
- (void)ninjaRunSlowTapped:(UIButton *)sender {
    Vars.NinjaRun_Slow = !Vars.NinjaRun_Slow;
    Vars.NinjaRun_Fast = NO;
    [self loadTabContent:MenuTabMSL];
}

- (void)ninjaRunFastTapped:(UIButton *)sender {
    Vars.NinjaRun_Fast = !Vars.NinjaRun_Fast;
    Vars.NinjaRun_Slow = NO;
    [self loadTabContent:MenuTabMSL];
}

- (void)toggleFastSwitch:(UISwitch *)s {
    FastSwitch = s.on;

    static bool wasswitch = false;
    if (FastSwitch) {
        void *addr[] = { (void *)getRealOffset(0x1051467BC) };
        void *func[] = { (void *)switchfast };
        Zexis(addr, func, 1);
        wasswitch = true;
    } else {
        if (wasswitch) {
            ZexisUnhook((void *)switchfast);
            wasswitch = false;
        }
    }

}

- (void)toggleStopLogs:(UISwitch *)s {
    StopGarenaLogs = s.on;
    // Add your stop logs logic here
}



- (void)toggleTheme {
    // Prevent race conditions - if already updating, ignore
    if (self.isUpdatingUI) {
        return;
    }
    self.isUpdatingUI = YES;
    
    isDarkMode = !isDarkMode;
    [self saveUIState]; // Save theme change immediately
    
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] 
        initWithStyle:UIImpactFeedbackStyleMedium];
    [fb impactOccurred];
    
    // Immediate update without animation for instant feedback
    [self updateAllColors];
    
    [UIView transitionWithView:themeToggle 
                      duration:0.3 
                       options:UIViewAnimationOptionTransitionFlipFromTop 
                    animations:^{
        [themeToggle setImage:[UIImage systemImageNamed:isDarkMode ? 
                               @"moon.fill" : @"sun.max.fill"] 
                     forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        self.isUpdatingUI = NO;
    }];
    
    // Force immediate UI refresh
    [self updateSidebarForTab:self.currentTab];
    [self updateHeaderForTab:self.currentTab];
    
    // Only reload content if not already changing tab
    if (!self.isChangingTab) {
        [self loadTabContent:self.currentTab];
    }
}

- (void)updateAllColors {
    // Update main panel background
    floatingPanel.backgroundColor = [self backgroundColor];
    
    // Update panel border
    floatingPanel.layer.borderColor = isDarkMode ? 
        [[UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.3] CGColor] : 
        [[UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.35] CGColor];
    
    // Update blur effect
    if (self.headerBlurView) {
        UIBlurEffect *newBlur = isDarkMode ? 
            [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark] : 
            [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.headerBlurView.effect = newBlur;
        
        // Update bottom border color
        for (CALayer *layer in self.headerBlurView.layer.sublayers) {
            if ([layer.name isEqualToString:@"bottomBorder"]) {
                layer.backgroundColor = [[self accentColor] colorWithAlphaComponent:0.2].CGColor;
            }
        }
    }
    
    // Update scroll indicator
    self.contentScrollView.indicatorStyle = isDarkMode ? 
        UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleBlack;
    
    // Update all buttons with semi-transparent background
    self.headerButton.backgroundColor = [[self pillColor] colorWithAlphaComponent:0.8];
    themeToggle.backgroundColor = [[self pillColor] colorWithAlphaComponent:0.8];
    closeButton.backgroundColor = [[self pillColor] colorWithAlphaComponent:0.8];
    
    // Update sidebar buttons
    for (UIButton *btn in self.tabButtons) {
        btn.backgroundColor = [self pillColor];
    }
    
    // Update separator
    UIView *separator = [floatingPanel viewWithTag:3000];
    if (separator) {
        separator.backgroundColor = [[self accentColor] colorWithAlphaComponent:0.15];
    }


    
    [self updateContentClipMask];
    [self updateSidebarClipMask];
    
    // Only reload content if not already changing tab
    if (!self.isChangingTab) {
        [self loadTabContent:self.currentTab];
    }

        [UIView animateWithDuration:0.4 
                          delay:0 
         usingSpringWithDamping:0.8 
          initialSpringVelocity:0.5 
                        options:0 
                     animations:^{ 
        [self updateAllColorsWithFade];
    } completion:nil];
}

#pragma mark - Feature Toggles

- (void)toggleEnable:(UISwitch *)s { 
    Vars.Enable = s.on; 

  
}

- (void)toggleBox:(UISwitch *)s { 
    Vars.Box = s.on; 
}

- (void)toggleLines:(UISwitch *)s { 
    Vars.lines = s.on; 
}

- (void)toggleSkeleton:(UISwitch *)s { 
    if (s) {
        Vars.Skeleton = s.on;
    }
}

- (void)toggleHealth:(UISwitch *)s { 
    if (s) {
        Vars.Health = s.on;
    }
}

- (void)toggleDistance:(UISwitch *)s { 
    if (s) {
        Vars.Distance = s.on;
    }
}

- (void)toggleName:(UISwitch *)s { 
    if (s) {
        Vars.Name = s.on;
    }
}

- (void)toggleOutline:(UISwitch *)s { 
    if (s) {
        Vars.Outline = s.on;
    }
}

- (void)toggleenemycount:(UISwitch *)s { 
    Vars.enemycount = s.on; 
}

- (void)toggleAimbot:(UISwitch *)s { 
    Vars.Aimbot = s.on; 
}
- (void)toggleAimsilent:(UISwitch *)s { 
    Vars.Aimsilent69 = s.on; 
}

- (void)toggleAimVisible:(UISwitch *)s { 
    Vars.Aimsilent69 = s.on; 
}

- (void)toggleIgnoreBot:(UISwitch *)s { 
    IgnoreBot = s.on; 
}

- (void)toggleIgnoreKnocked2:(UISwitch *)s { 
    IgnoreKnocked2 = s.on; 
}

- (void)toggleexa:(UISwitch *)s { 
    Vars.ShowEn = s.on; 
}


- (void)toggleAimKill:(UISwitch *)s { 
    Vars.playertakedamage2T = s.on; 
}


- (void)toggleRateOfFire:(UISwitch *)s { 
    Vars.rateoffire = s.on; 
}

- (void)sliderChanged:(UISlider *)s { 
    Vars.AimFov = s.value; 
    UILabel *vl = objc_getAssociatedObject(s, "valueLabel"); 
    if (vl) {
        vl.text = [NSString stringWithFormat:@"%.0f", s.value]; 
    }
}

- (void)fovThicknessChanged:(UISlider *)s {
    AimbotFOVThickness = s.value;
    UILabel *vl = objc_getAssociatedObject(s, "valueLabel");
    if (vl) {
        vl.text = [NSString stringWithFormat:@"%.1f", s.value];
    }
}

- (void)triggerChanged:(UISegmentedControl *)s { 
    Vars.AimWhen = (int)s.selectedSegmentIndex; 
}

- (void)targetChanged:(UISegmentedControl *)s { 
    Vars.Target = (AimTarget)s.selectedSegmentIndex; 
}


- (void)toggleSpeedHack:(UISwitch *)s { 
    SpeedHack = s.on; 
}

- (void)toggleUpPlayer:(UISwitch *)s { 
    Vars.UpPlayer = s.on; 
}

- (void)toggleTelekill:(UISwitch *)s { 
    Vars.Telekill = s.on;
    [self saveSettingsToFile]; // Save settings so it persists when menu closes
}

- (void)toggleUndergroundKill2:(UISwitch *)s { 
    Vars.UndergroundKill2 = s.on; 
}

- (void)toggleNinjaRun:(UISwitch *)s { 
    Vars.NinjaRun = s.on; 
}



- (void)toggleResetGuest:(UISwitch *)s { 
    Guest2 = s.on; 
    
    static bool wasGuestHooked = false;
    if (Guest2) {
        void *addr[] = { (void *)getRealOffset(0x10126E688) };
        void *func[] = { (void *)Guest };
        Zexis(addr, func, 1);
        wasGuestHooked = true;
    } else {
        if (wasGuestHooked) {
            ZexisUnhook((void *)Guest);
            wasGuestHooked = false;
        }
    }
}



- (void)toggleFastMedkit:(UISwitch *)s { 
    fmedkit = s.on; 
    
    static bool wasfmHooked = false;
    if (fmedkit) {
        void *addr[] = { (void *)getRealOffset(0x1052C30C8) };
        void *func[] = { (void *)fastmedkit };
        Zexis(addr, func, 1);
        wasfmHooked = true;
    } else {
        if (wasfmHooked) {
            ZexisUnhook((void *)fastmedkit);
            wasfmHooked = false;
        }
    }
}


- (void)toggleForce120FPS:(UISwitch *)s { 
    HighFPS = s.on; 
    
    static bool wasFrame = false;
    if (HighFPS) {
        void *addr[] = { (void *)getRealOffset(0x1005FF44C) };
        void *func[] = { (void *)SetHighFPS };
        Zexis(addr, func, 1);
        wasFrame = true;
    } else {
        if (wasFrame) {
            ZexisUnhook((void *)SetHighFPS);
            wasFrame = false;
        }
    }
}

- (void)toggleBloodIndia:(UISwitch *)s { 
    ClearCache = s.on;
}

- (void)toggleTeleport8m:(UISwitch *)s { 
    Vars.Telekill = s.on;
    [self saveSettingsToFile]; // Save settings so it persists when menu closes
}

- (void)savePosSwitchChanged:(UISwitch *)sender {
    testGhost = sender.on;
}

- (void)updateUIButtonVisibility {
    // Prevent race conditions
    if (self.isUpdatingUI) {
        return;
    }
    self.isUpdatingUI = YES;
    
    
    self.isUpdatingUI = NO;
}

- (void)toggleFly:(UISwitch *)s {
    Vars.fly = s.on;
}

- (void)flyHeightChanged:(UISlider *)slider {
    Vars.flyHeight = slider.value;
    
    UILabel *valueLabel = objc_getAssociatedObject(slider, "valueLabel");
    if (valueLabel) {
        valueLabel.text = [NSString stringWithFormat:@"%.1f", slider.value];
    }
}

- (void)toggleStreamMode:(UISwitch *)s { 
    StreamMode = s.on;
    SetStreamMode(s.on); 
    if (s.on) { 
        if (floatingPanel) UpdateStreamProtectionForView(floatingPanel); 
        if (self.view) UpdateStreamProtectionForView(self.view); 
        [self protectAllFeatureButtons]; 
        reapplyStreamModeToAllESP();
    } else { 
        if (floatingPanel) UpdateStreamProtectionForView(floatingPanel); 
        if (self.view) UpdateStreamProtectionForView(self.view); 
        [self unprotectAllFeatureButtons];
    } 
}

- (void)protectAllFeatureButtons { 
    // Feature buttons removed
}

- (void)unprotectAllFeatureButtons { 
    // Feature buttons removed
}


- (void)animatePanelEntrance { 
    floatingPanel.alpha = 0.0; 
    floatingPanel.transform = CGAffineTransformMakeScale(0.85, 0.85); 
    [UIView animateWithDuration:0.6 
                          delay:0.0 
         usingSpringWithDamping:0.7 
          initialSpringVelocity:0.9 
                        options:0 
                     animations:^{ 
        floatingPanel.alpha = 1.0; 
        floatingPanel.transform = CGAffineTransformIdentity; 
    } completion:nil]; 
}

- (void)handleDrag:(UIPanGestureRecognizer *)g { 
    UIView *v = g.view; 
    CGPoint t = [g translationInView:v.superview]; 
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y); 
    [g setTranslation:CGPointZero inView:v.superview]; 
    if (g.state == UIGestureRecognizerStateEnded) {
        [self savePanelPosition:v.frame.origin]; 
    }
}

- (void)handleOutsideTap:(UITapGestureRecognizer *)g { 
    CGPoint loc = [g locationInView:self.view];
    
    // Check if tap is outside tab selector
    // Tab selector popup removed - no check needed
    
    // Close menu if tap is outside floating panel
    if (!CGRectContainsPoint(floatingPanel.frame, loc)) {
        [self hideTabSelector]; 
        [self animateClose]; 
    }
}

- (void)closeSelf { 
    [self.fpsTimer invalidate]; 
    self.fpsTimer = nil; 
    [self saveUIState];
    
    
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:@"ModMenuDidClose" object:nil]; 
    [self dismissViewControllerAnimated:NO completion:nil]; 
}


- (void)animateClose { 
    [UIView animateWithDuration:0.35 
                          delay:0.0 
         usingSpringWithDamping:0.9 
          initialSpringVelocity:0.5 
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:^{ 
        floatingPanel.alpha = 0.0; 
        floatingPanel.transform = CGAffineTransformMakeScale(0.85, 0.85);
        floatingPanel.center = CGPointMake(
            floatingPanel.center.x, 
            floatingPanel.center.y + 20);
    } completion:^(BOOL f) { 
        [self closeSelf]; 
    }]; 
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gr 
       shouldReceiveTouch:(UITouch *)touch { 
    return ![touch.view isDescendantOfView:floatingPanel]; 
}

- (void)screenCaptureStatusChanged:(NSNotification *)n { 
    if (StreamMode) { 
        if (floatingPanel) UpdateStreamProtectionForView(floatingPanel); 
        if (self.view) UpdateStreamProtectionForView(self.view); 
        [self protectAllFeatureButtons]; 
    } 
}

- (void)savePanelPosition:(CGPoint)origin { 
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults]; 
    [d setFloat:origin.x forKey:@"ModMenuPanelX"]; 
    [d setFloat:origin.y forKey:@"ModMenuPanelY"]; 
    [d synchronize]; 
}

- (CGPoint)loadPanelPosition { 
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults]; 
    CGFloat x = [d floatForKey:@"ModMenuPanelX"]; 
    CGFloat y = [d floatForKey:@"ModMenuPanelY"]; 
    if (x == 0 && y == 0) {
        return CGPointMake(40, 100); 
    }
    return CGPointMake(x, y); 
}

@end
