// FilzaAuthGate.m
// Ponto de integração de referência para o tweak autorizado. Chame
// FilzaAuthPresentIfNeeded(viewController) no primeiro controlador visível.
#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@end

static BOOL FilzaAuthGateIsPresented = NO;

void FilzaAuthPresentIfNeeded(UIViewController *host) {
  if (!host || FilzaAuthGateIsPresented || host.presentedViewController) return;
  FilzaAuthGateIsPresented = YES;
  LoginViewController *login = [LoginViewController new];
  UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:login];
  navigation.modalPresentationStyle = UIModalPresentationFullScreen;
  [host presentViewController:navigation animated:NO completion:nil];
}

// Exemplo de uso dentro de um hook autorizado:
// static void hook_viewDidAppear(id self, SEL _cmd, BOOL animated) {
//   ((void(*)(id, SEL, BOOL))orig_viewDidAppear)(self, _cmd, animated);
//   FilzaAuthPresentIfNeeded((UIViewController *)self);
// }
