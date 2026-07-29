#import "PubgLoad.h"
#import <UIKit/UIKit.h>
#include "oxorany/oxorany_include.h"
#import "JHPP.h"
#import "JHDragView.h"
#import "menuUIKIT/drawview.h"

#pragma mark - Main Tweak Entry

@implementation PubgLoad

static PubgLoad *extraInfo;
static BOOL isMenuOpen = NO;
static BOOL initDone = NO;
static UIButton *triggerBtn = nil;
static UIWindow *overlayWin = nil;

#pragma mark - Initialization

+ (void)load {
    [super load];
    // Retry every 1s for up to 10 seconds to find the main window
    [self tryInitWithRemaining:10];
}

+ (void)tryInitWithRemaining:(int)remaining {
    if (remaining <= 0 || initDone) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (initDone) return;
        
        @try {
            UIWindow *win = [UIApplication sharedApplication].keyWindow;
            if (!win) win = [[UIApplication sharedApplication].delegate window];
            
            if (win && win.rootViewController && !initDone) {
                initDone = YES;
                extraInfo = [PubgLoad new];
                [extraInfo createOverlayButton];
                
                [[NSNotificationCenter defaultCenter] addObserver:extraInfo
                                                         selector:@selector(menuDidClose)
                                                             name:@"ModMenuDidClose"
                                                           object:nil];
                NSLog(@"[FFZ] ✓ Initialized!");
            } else {
                [PubgLoad tryInitWithRemaining:remaining - 1];
            }
        } @catch (NSException *e) {
            NSLog(@"[FFZ] Error: %@", e.reason);
            [PubgLoad tryInitWithRemaining:remaining - 1];
        }
    });
}

#pragma mark - Overlay Window + Button

- (void)createOverlayButton {
    if (triggerBtn) return;
    
    // Load saved position
    CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:@"FFZ_Menu_X"];
    CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:@"FFZ_Menu_Y"];
    if (x < 1 && y < 1) { x = 20; y = 120; }
    
    CGFloat btnSize = 50;
    
    // Create overlay window ABOVE Unity's rendering level
    overlayWin = [[UIWindow alloc] initWithFrame:CGRectMake(x, y, btnSize, btnSize)];
    overlayWin.windowLevel = UIWindowLevelAlert + 100;  // Above Unity
    overlayWin.backgroundColor = [UIColor clearColor];
    overlayWin.userInteractionEnabled = YES;
    overlayWin.clipsToBounds = NO;
    
    // Small overlay windows don't need rootViewController
    // But some iOS versions require one for touch handling
    UIViewController *dummyRoot = [[UIViewController alloc] init];
    dummyRoot.view.backgroundColor = [UIColor clearColor];
    dummyRoot.view.userInteractionEnabled = NO;  // Pass touches through to window
    overlayWin.rootViewController = dummyRoot;
    
    // Create simple trigger button
    triggerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    triggerBtn.frame = CGRectMake(0, 0, btnSize, btnSize);
    triggerBtn.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.85];
    triggerBtn.layer.cornerRadius = btnSize / 2;
    triggerBtn.layer.borderWidth = 2.5;
    triggerBtn.layer.borderColor = [UIColor colorWithRed:1.0 green:0.5 blue:0 alpha:0.9].CGColor;
    triggerBtn.clipsToBounds = YES;
    [triggerBtn setTitle:@"⚡" forState:UIControlStateNormal];
    triggerBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    triggerBtn.userInteractionEnabled = YES;
    
    // Tap → open menu
    [triggerBtn addTarget:extraInfo action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // Drag → move button
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:extraInfo action:@selector(dragButton:)];
    [triggerBtn addGestureRecognizer:pan];
    
    // Add button DIRECTLY to overlay window (not root VC's view!)
    [overlayWin addSubview:triggerBtn];
    
    // Show the window
    overlayWin.hidden = NO;
    
    NSLog(@"[FFZ] ✓ ⚡ Button at (%.0f, %.0f) via overlay window", x, y);
}

#pragma mark - Button Actions

- (void)buttonTapped {
    if (isMenuOpen) return;
    [self openMenu];
}

- (void)dragButton:(UIPanGestureRecognizer *)g {
    if (!overlayWin) return;
    UIView *btn = g.view;
    CGPoint t = [g translationInView:btn.superview];
    btn.center = CGPointMake(btn.center.x + t.x, btn.center.y + t.y);
    [g setTranslation:CGPointZero inView:btn.superview];
    
    if (g.state == UIGestureRecognizerStateEnded) {
        // Move overlay window to follow button
        CGRect absFrame = [btn.superview convertRect:btn.frame toView:nil];
        overlayWin.frame = absFrame;
        btn.frame = overlayWin.bounds;
        
        [[NSUserDefaults standardUserDefaults] setFloat:absFrame.origin.x forKey:@"FFZ_Menu_X"];
        [[NSUserDefaults standardUserDefaults] setFloat:absFrame.origin.y forKey:@"FFZ_Menu_Y"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Menu Actions

- (void)openMenu {
    if (isMenuOpen) return;
    isMenuOpen = YES;
    triggerBtn.hidden = YES;
    
    UIWindow *mainWin = [UIApplication sharedApplication].keyWindow;
    if (!mainWin) mainWin = [[UIApplication sharedApplication].delegate window];
    UIViewController *rootVC = mainWin.rootViewController;
    if (!rootVC) {
        isMenuOpen = NO;
        triggerBtn.hidden = NO;
        return;
    }
    
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    
    ModMenuViewController *menuVC = [[ModMenuViewController alloc] init];
    menuVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootVC presentViewController:menuVC animated:NO completion:nil];
}

- (void)closeMenu {
    if (!isMenuOpen) {
        triggerBtn.hidden = NO;
        return;
    }
    
    UIWindow *mainWin = [UIApplication sharedApplication].keyWindow;
    if (!mainWin) mainWin = [[UIApplication sharedApplication].delegate window];
    UIViewController *topVC = mainWin.rootViewController;
    if (!topVC) {
        isMenuOpen = NO;
        triggerBtn.hidden = NO;
        return;
    }
    
    while (topVC.presentedViewController) {
        if ([topVC.presentedViewController isKindOfClass:[ModMenuViewController class]]) {
            [topVC.presentedViewController dismissViewControllerAnimated:NO completion:^{
                isMenuOpen = NO;
                triggerBtn.hidden = NO;
            }];
            return;
        }
        topVC = topVC.presentedViewController;
    }
    
    isMenuOpen = NO;
    triggerBtn.hidden = NO;
}

- (void)menuDidClose {
    isMenuOpen = NO;
    triggerBtn.hidden = NO;
}

@end
