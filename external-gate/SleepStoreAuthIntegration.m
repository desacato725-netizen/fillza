// FilzaAuthIntegration.m
// Inclua este arquivo no alvo Theos da FilzaApplySandboxExt junto de
// LoginViewController.m e FilzaAuthGate.m. Ele não usa identificadores de
// hardware nem intercepta dados do usuário; apenas apresenta o gate autorizado.
#import <UIKit/UIKit.h>

extern void FilzaAuthPresentIfNeeded(UIViewController *host);

__attribute__((constructor)) static void FilzaAuthInstallApplicationGate(void) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
      UIApplication *application = UIApplication.sharedApplication;
      UIWindow *window = nil;
      for (UIWindow *candidate in application.windows) if (candidate.isKeyWindow) { window = candidate; break; }
      UIViewController *host = window.rootViewController;
      while (host.presentedViewController && ![host.presentedViewController isBeingDismissed]) host = host.presentedViewController;
      if (host) FilzaAuthPresentIfNeeded(host);
    }];
  });
}
