#import "PubgLoad.h"
#import <UIKit/UIKit.h>
#include "oxorany/oxorany_include.h"
#import "JHPP.h"
#import "JHDragView.h"
#import "menuUIKIT/drawview.h"

#pragma mark - Floating Trigger Button

@interface MenuTriggerButton : UIView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, copy) void (^onTap)(void);
@end

@implementation MenuTriggerButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:0.5 blue:0 alpha:0.8].CGColor;
        self.userInteractionEnabled = YES;
        
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.text = @"⚡";
        self.label.font = [UIFont systemFontOfSize:20];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        [self addSubview:self.label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:tap];
        
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
        [[NSUserDefaults standardUserDefaults] setFloat:self.frame.origin.x forKey:@"FFZ_Menu_X"];
        [[NSUserDefaults standardUserDefaults] setFloat:self.frame.origin.y forKey:@"FFZ_Menu_Y"];
    }
}

@end


#pragma mark - Main Tweak Entry

@implementation PubgLoad

static PubgLoad *extraInfo;
static BOOL isUIKitMenuOpen = NO;
static BOOL initDone = NO;
static MenuTriggerButton *triggerBtn = nil;
UIWindow *mainWindow;

#pragma mark - Initialization

+ (void)load {
    [super load];
    [self tryInitWithDelay:1 remaining:10];
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
            [extraInfo setupAllTriggers];
            [[NSNotificationCenter defaultCenter] addObserver:extraInfo
                                                     selector:@selector(menuDidClose)
                                                         name:@"ModMenuDidClose"
                                                       object:nil];
            NSLog(@"[FFZ] ✓ Initialized at %ds", delay);
        } else if (!initDone) {
            [PubgLoad tryInitWithDelay:1 remaining:remaining - 1];
        }
    });
}

#pragma mark - Setup Triggers (Button + Gesture)

- (void)setupAllTriggers {
    [self showTriggerButton];
    [self addGestureTriggers];
}

- (void)showTriggerButton {
    if (triggerBtn) return;
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    if (!win) return;
    
    CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:@"FFZ_Menu_X"];
    CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:@"FFZ_Menu_Y"];
    if (x < 1 && y < 1) { x = 20; y = 120; }
    
    triggerBtn = [[MenuTriggerButton alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
    triggerBtn.onTap = ^{ [extraInfo openMenu]; };
    [win addSubview:triggerBtn];
    NSLog(@"[FFZ] ✓ Floating button added");
}

- (void)addGestureTriggers {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    UIView *target = win ?: [JHPP currentViewController].view;
    
    // OPTION 1: 3-Finger Double Tap → Open Menu
    UITapGestureRecognizer *openTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
    openTap.numberOfTapsRequired = 2;
    openTap.numberOfTouchesRequired = 3;
    openTap.delaysTouchesEnded = NO;
    [target addGestureRecognizer:openTap];
    
    // OPTION 2: 2-Finger Single Tap → Close Menu
    UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenu)];
    closeTap.numberOfTapsRequired = 1;
    closeTap.numberOfTouchesRequired = 2;
    closeTap.delaysTouchesEnded = NO;
    [target addGestureRecognizer:closeTap];
    
    NSLog(@"[FFZ] ✓ Gesture triggers added to: %@", [target class]);
    
    // Notify user about available triggers
    NSLog(@"[FFZ] ▶ Open: ⚡ button tap OR 3-finger double tap");
    NSLog(@"[FFZ] ▶ Close: 2-finger single tap OR menu close button");
}

#pragma mark - Menu Actions

- (void)openMenu {
    if (isUIKitMenuOpen) return;
    triggerBtn.hidden = YES;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootVC = window.rootViewController;
    if (!window || !rootVC) return;
    
    ModMenuViewController *menuVC = [[ModMenuViewController alloc] init];
    menuVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootVC presentViewController:menuVC animated:NO completion:^{
        isUIKitMenuOpen = YES;
    }];
}

- (void)closeMenu {
    if (!isUIKitMenuOpen) return;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = window.rootViewController.presentedViewController;
    if ([vc isKindOfClass:[ModMenuViewController class]]) {
        [vc dismissViewControllerAnimated:NO completion:^{
            isUIKitMenuOpen = NO;
            triggerBtn.hidden = NO;
        }];
    }
}

- (void)menuDidClose {
    isUIKitMenuOpen = NO;
    triggerBtn.hidden = NO;
}

@end
