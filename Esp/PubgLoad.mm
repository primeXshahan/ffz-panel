#import "PubgLoad.h"
#import <UIKit/UIKit.h>
#include "oxorany/oxorany_include.h"
#import "JHPP.h"
#import "JHDragView.h"
#import "menuUIKIT/drawview.h"

@implementation PubgLoad

static PubgLoad *extraInfo;
static BOOL isUIKitMenuOpen = NO;
static BOOL initDone = NO;
UIWindow *mainWindow;

#pragma mark - Initialization (retries up to 8s until window is ready)

+ (void)load {
    [super load];
    [self tryInitWithDelay:1 remaining:8];
}

+ (void)tryInitWithDelay:(int)delay remaining:(int)remaining {
    if (remaining <= 0 || initDone) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [JHPP currentViewController];
        
        if (win && vc && vc.isViewLoaded && vc.view.window && !initDone) {
            initDone = YES;
            mainWindow = win;
            extraInfo = [PubgLoad new];
            [extraInfo initGestures];
            NSLog(@"[FFZ] ✓ Menu initialized at %ds", delay);
        } else if (!initDone) {
            [PubgLoad tryInitWithDelay:1 remaining:remaining - 1];
        }
    });
}

#pragma mark - Gesture Setup (attached to keyWindow for reliability)

- (void)initGestures {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    UIView *target = win ?: [JHPP currentViewController].view;
    
    // 3-Finger Double Tap → Open Menu
    UITapGestureRecognizer *openTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
    openTap.numberOfTapsRequired = 2;
    openTap.numberOfTouchesRequired = 3;
    openTap.delaysTouchesEnded = NO;
    [target addGestureRecognizer:openTap];
    
    // 2-Finger Single Tap → Close Menu
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    closeTap.numberOfTapsRequired = 1;
    closeTap.numberOfTouchesRequired = 2;
    closeTap.delaysTouchesEnded = NO;
    [target addGestureRecognizer:closeTap];
    
    // Listen for menu-close notifications from the menu itself
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidClose)
                                                 name:@"ModMenuDidClose"
                                               object:nil];
    
    NSLog(@"[FFZ] ✓ Gestures added to: %@", [target class]);
}

#pragma mark - Menu Actions

- (void)openMenu {
    if (isUIKitMenuOpen) return;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootVC = window.rootViewController;
    if (!window || !rootVC) return;
    
    ModMenuViewController *menuVC = [[ModMenuViewController alloc] init];
    menuVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootVC presentViewController:menuVC animated:NO completion:^{
        isUIKitMenuOpen = YES;
    }];
}

- (void)menuDidClose {
    isUIKitMenuOpen = NO;
}

- (void)closeMenu {
    if (!isUIKitMenuOpen) return;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = window.rootViewController.presentedViewController;
    if ([vc isKindOfClass:[ModMenuViewController class]]) {
        [vc dismissViewControllerAnimated:NO completion:^{
            isUIKitMenuOpen = NO;
        }];
    } else {
        isUIKitMenuOpen = NO;
    }
}

@end
