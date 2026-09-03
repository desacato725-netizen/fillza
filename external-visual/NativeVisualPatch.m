#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static const NSInteger SleepStoreVisualTag = 0x534C50;
static void (*SleepStoreOriginalViewDidAppear)(id, SEL, BOOL);

@interface SleepStoreDiscordTarget : NSObject
@end

@implementation SleepStoreDiscordTarget
- (void)openDiscord:(id)sender {
  NSURL *url = [NSURL URLWithString:@"https://discord.gg/sleepff"];
  [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}
@end

static SleepStoreDiscordTarget *SleepStoreSharedDiscordTarget(void) {
  static SleepStoreDiscordTarget *target;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ target = [SleepStoreDiscordTarget new]; });
  return target;
}

static void SleepStoreApplyVisual(id controller) {
  UIView *root = nil;
  @try { root = [controller valueForKey:@"view"]; } @catch (__unused NSException *exception) { return; }
  if (!root || [root viewWithTag:SleepStoreVisualTag]) return;

  UITextField *keyField = nil;
  UIButton *loginButton = nil;
  @try {
    keyField = [controller valueForKey:@"keyField"];
    loginButton = [controller valueForKey:@"loginButton"];
  } @catch (__unused NSException *exception) {}
  if (keyField) keyField.placeholder = @"SLEEP STORE key";

  UILabel *brand = [[UILabel alloc] initWithFrame:CGRectZero];
  brand.tag = SleepStoreVisualTag;
  brand.text = @"sleepffx  ·  dev|cholyyk";
  brand.textColor = [UIColor colorWithWhite:0.92 alpha:0.92];
  brand.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
  brand.textAlignment = NSTextAlignmentCenter;
  brand.translatesAutoresizingMaskIntoConstraints = NO;
  [root addSubview:brand];

  UIButton *discord = [UIButton buttonWithType:UIButtonTypeSystem];
  [discord setTitle:@"Discord · sleepffx" forState:UIControlStateNormal];
  [discord setTitleColor:[UIColor colorWithWhite:0.76 alpha:0.95] forState:UIControlStateNormal];
  discord.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
  discord.translatesAutoresizingMaskIntoConstraints = NO;
  [discord addTarget:SleepStoreSharedDiscordTarget() action:@selector(openDiscord:) forControlEvents:UIControlEventTouchUpInside];
  [root addSubview:discord];

  [NSLayoutConstraint activateConstraints:@[
    [brand.centerXAnchor constraintEqualToAnchor:root.centerXAnchor],
    [brand.bottomAnchor constraintEqualToAnchor:discord.topAnchor constant:-4],
    [discord.centerXAnchor constraintEqualToAnchor:root.centerXAnchor],
    [discord.bottomAnchor constraintEqualToAnchor:root.safeAreaLayoutGuide.bottomAnchor constant:-18],
    [discord.heightAnchor constraintEqualToConstant:28]
  ]];

  if (loginButton) loginButton.accessibilityHint = @"Login SLEEP STORE";
}

static void SleepStorePatchedViewDidAppear(id self, SEL _cmd, BOOL animated) {
  if (SleepStoreOriginalViewDidAppear) SleepStoreOriginalViewDidAppear(self, _cmd, animated);
  dispatch_async(dispatch_get_main_queue(), ^{ SleepStoreApplyVisual(self); });
}

__attribute__((constructor)) static void SleepStoreInstallVisualPatch(void) {
  dispatch_async(dispatch_get_main_queue(), ^{
    Class cls = objc_getClass("ViewController");
    SEL selector = @selector(viewDidAppear:);
    Method method = cls ? class_getInstanceMethod(cls, selector) : NULL;
    if (!method) return;
    SleepStoreOriginalViewDidAppear = (void (*)(id, SEL, BOOL))method_getImplementation(method);
    method_setImplementation(method, (IMP)SleepStorePatchedViewDidAppear);
  });
}
