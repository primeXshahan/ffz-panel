#import "PubgLoad.h"
#import <UIKit/UIKit.h>
#include "oxorany/oxorany_include.h"
#import <QuartzCore/QuartzCore.h>
#import "JHPP.h"
#import "JHDragView.h"
#import "menuUIKIT/drawview.h"

#pragma mark - File-scope statics (accessible by all classes in this file)

static PubgLoad *extraInfo;
static BOOL isUIKitMenuOpen = NO;
static BOOL initDone = NO;
static MenuTriggerButton *triggerBtn = nil;
static UIWindow *overlayWindow = nil;

#pragma mark - Floating Trigger Button (⚡)

@interface MenuTriggerButton : UIView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, copy) void (^onTap)(void);
@end

@implementation MenuTriggerButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.12 alpha:0.85];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.borderWidth = 2.5;
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:0.5 blue:0 alpha:0.9].CGColor;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        // Pulse animation to make it noticeable
        CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulse.fromValue = @(1.0);
        pulse.toValue = @(1.1);
        pulse.duration = 1.0;
        pulse.autoreverses = YES;
        pulse.repeatCount = HUGE_VALF;
        pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.layer addAnimation:pulse forKey:@"pulse"];
        
        // ⚡ label
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.text = @"⚡";
        self.label.font = [UIFont systemFontOfSize:24];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        [self addSubview:self.label];
        
        // Tap to open menu
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:tap];
        
        // Drag to move
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)didTap { if (self.onTap) self.onTap(); }

- (void)didPan:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self.superview];
    self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
    [g setTranslation:CGPointZero inView:self.superview];
    
    if (g.state == UIGestureRecognizerStateEnded) {
        // Move overlay window to follow the button
        CGRect absFrame = [self.superview convertRect:self.frame toView:nil];
        overlayWindow.frame = absFrame;
        self.frame = (CGRect){CGPointZero, self.frame.size};
        
        // Save position
        [[NSUserDefaults standardUserDefaults] setFloat:absFrame.origin.x forKey:@"FFZ_Menu_X"];
        [[NSUserDefaults standardUserDefaults] setFloat:absFrame.origin.y forKey:@"FFZ_Menu_Y"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end


#pragma mark - Main Tweak Entry

@implementation PubgLoad

#pragma mark - Initialization

+ (void)load {
    [super load];
    // Start trying after 0.5s, retry every 0.5s for up to 20 attempts (10s total)
    [self tryInitWithDelay:0.5 remaining:20];
}

+ (void)tryInitWithDelay:(NSTimeInterval)delay remaining:(int)remaining {
    if (remaining <= 0 || initDone) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (initDone) return;
        
        // Try to get ANY window
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) win = [UIApplication sharedApplication].delegate.window;
        // As last resort, get the first window from connectedScenes
        if (!win) {
            if (@available(iOS 13.0, *)) {
                for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        UIWindowScene *ws = (UIWindowScene *)scene;
                        win = ws.keyWindow ?: [ws.windows firstObject];
                        if (win) break;
                    }
                }
            }
        }
        
        if (win && win.rootViewController && !initDone) {
            initDone = YES;
            extraInfo = [PubgLoad new];
            [extraInfo setupTriggers:win];
            
            [[NSNotificationCenter defaultCenter] addObserver:extraInfo
                                                     selector:@selector(menuDidClose)
                                                         name:@"ModMenuDidClose"
                                                       object:nil];
            NSLog(@"[FFZ] ✓ Initialized successfully!");
        } else {
            [PubgLoad tryInitWithDelay:0.5 remaining:remaining - 1];
        }
    });
}

#pragma mark - Create Overlay Window (with UIWindowScene support for iOS 13+)

- (UIWindow *)createOverlayWindowInScene:(UIWindow *)mainWin withFrame:(CGRect)frame {
    UIWindow *ow = nil;
    
    if (@available(iOS 13.0, *)) {
        // iOS 13+ requires UIWindowScene for new windows
        UIWindowScene *scene = mainWin.windowScene;
        if (!scene) {
            // Try to get scene from connected scenes
            for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
                if ([s isKindOfClass:[UIWindowScene class]]) {
                    scene = (UIWindowScene *)s;
                    break;
                }
            }
        }
        if (scene) {
            ow = [[UIWindow alloc] initWithWindowScene:scene];
        } else {
            // Fallback: no scene found (pre-iOS 13 or single-window app)
            ow = [[UIWindow alloc] initWithFrame:frame];
        }
    } else {
        // iOS 12 and below
        ow = [[UIWindow alloc] initWithFrame:frame];
    }
    
    ow.frame = frame;
    ow.windowLevel = UIWindowLevelAlert + 100;
    ow.hidden = NO;
    ow.userInteractionEnabled = YES;
    ow.backgroundColor = [UIColor clearColor];
    
    // Set a minimal root VC so the window is fully functional
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor clearColor];
    rootVC.view.userInteractionEnabled = NO;  // Pass through touches to window
    ow.rootViewController = rootVC;
    
    return ow;
}

#pragma mark - Setup Floating Button

- (void)setupTriggers:(UIWindow *)mainWin {
    [self createFloatingButtonWithWindow:mainWin];
}

- (void)createFloatingButtonWithWindow:(UIWindow *)mainWin {
    if (triggerBtn) return;
    if (!mainWin) return;
    
    // Load saved position
    CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:@"FFZ_Menu_X"];
    CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:@"FFZ_Menu_Y"];
    if (x < 1 && y < 1) { x = 20; y = 120; }
    
    CGFloat btnSize = 50;
    
    // Create overlay window (scene-aware)
    overlayWindow = [self createOverlayWindowInScene:mainWin
                                           withFrame:CGRectMake(x, y, btnSize, btnSize)];
    
    // Create the trigger button
    triggerBtn = [[MenuTriggerButton alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
    triggerBtn.onTap = ^{ [extraInfo openMenu]; };
    // Add to overlay window directly (NOT to root VC's view — it has userInteractionEnabled=NO for pass-through)
    [overlayWindow addSubview:triggerBtn];
    
    NSLog(@"[FFZ] ✓ ⚡ Button created at (%.0f, %.0f) - windowScene: %@",
          x, y, overlayWindow.windowScene ? @"✅" : @"❌");
}

#pragma mark - Menu Actions

- (void)openMenu {
    if (isUIKitMenuOpen) return;
    isUIKitMenuOpen = YES;
    
    triggerBtn.hidden = YES;
    
    // Get main game window
    UIWindow *mainWin = [UIApplication sharedApplication].keyWindow;
    if (!mainWin) mainWin = [UIApplication sharedApplication].delegate.window;
    if (!mainWin) {
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    mainWin = [(UIWindowScene *)scene keyWindow];
                    if (mainWin) break;
                }
            }
        }
    }
    
    UIViewController *rootVC = mainWin.rootViewController;
    if (!rootVC) {
        isUIKitMenuOpen = NO;
        triggerBtn.hidden = NO;
        return;
    }
    
    // Find top-most presented VC
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    
    ModMenuViewController *menuVC = [[ModMenuViewController alloc] init];
    menuVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootVC presentViewController:menuVC animated:NO completion:nil];
}

- (void)closeMenu {
    if (!isUIKitMenuOpen) return;
    
    UIWindow *mainWin = [UIApplication sharedApplication].keyWindow;
    if (!mainWin) mainWin = [UIApplication sharedApplication].delegate.window;
    UIViewController *topVC = mainWin.rootViewController;
    if (!topVC) {
        isUIKitMenuOpen = NO;
        triggerBtn.hidden = NO;
        return;
    }
    
    // Traverse presented VCs to find and dismiss ModMenuViewController
    while (topVC.presentedViewController) {
        if ([topVC.presentedViewController isKindOfClass:[ModMenuViewController class]]) {
            [topVC.presentedViewController dismissViewControllerAnimated:NO completion:^{
                isUIKitMenuOpen = NO;
                triggerBtn.hidden = NO;
            }];
            return;
        }
        topVC = topVC.presentedViewController;
    }
    
    // Fallback
    isUIKitMenuOpen = NO;
    triggerBtn.hidden = NO;
}

- (void)menuDidClose {
    isUIKitMenuOpen = NO;
    triggerBtn.hidden = NO;
}

@end
