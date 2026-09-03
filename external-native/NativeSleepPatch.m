#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <objc/runtime.h>

static NSString * const SleepAPI = @"https://sleeppanel-by9jc9qe.manus.space";
static NSString * const SleepKeyTag = @"com.filzaslop.device-key";
static NSString * const SleepTokenTag = @"com.filzaslop.device-token";
static NSString * const SleepInstallMarker = @"com.filzaslop.installation-marker";

@interface SleepNativeBridge : NSObject
@property(nonatomic,weak) UIViewController *controller;
@property(nonatomic,assign) SecKeyRef privateKey;
@end

@implementation SleepNativeBridge
- (void)dealloc { if (self.privateKey) CFRelease(self.privateKey); }

- (void)ensureDeviceKey {
  NSData *tag=[SleepKeyTag dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *q=@{(__bridge id)kSecClass:(__bridge id)kSecClassKey,(__bridge id)kSecAttrApplicationTag:tag,(__bridge id)kSecReturnRef:@YES};
  SecKeyRef existing=NULL;
  if(SecItemCopyMatching((__bridge CFDictionaryRef)q,(CFTypeRef *)&existing)==errSecSuccess){self.privateKey=existing;return;}
  NSDictionary *a=@{(__bridge id)kSecAttrKeyType:(__bridge id)kSecAttrKeyTypeECSECPrimeRandom,(__bridge id)kSecAttrKeySizeInBits:@256,(__bridge id)kSecPrivateKeyAttrs:@{(__bridge id)kSecAttrIsPermanent:@YES,(__bridge id)kSecAttrApplicationTag:tag}};
  CFErrorRef e=NULL; self.privateKey=SecKeyCreateRandomKey((__bridge CFDictionaryRef)a,&e); if(e)CFRelease(e);
}
- (NSString *)publicKeyPEM {
  SecKeyRef pub=SecKeyCopyPublicKey(self.privateKey); CFErrorRef e=NULL; CFDataRef d=SecKeyCopyExternalRepresentation(pub,&e); if(pub)CFRelease(pub); if(!d){if(e)CFRelease(e);return nil;}
  NSString *b64=[(__bridge NSData *)d base64EncodedStringWithOptions:0]; CFRelease(d); return [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----",b64];
}
- (void)post:(NSDictionary *)body path:(NSString *)path completion:(void (^)(NSDictionary *,NSError *))completion {
  NSURL *url=[NSURL URLWithString:[SleepAPI stringByAppendingString:path]]; NSMutableURLRequest *r=[NSMutableURLRequest requestWithURL:url]; r.HTTPMethod=@"POST"; [r setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; r.HTTPBody=[NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
  [[[NSURLSession sharedSession] dataTaskWithRequest:r completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){ NSDictionary *json=data?[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]:@{}; dispatch_async(dispatch_get_main_queue(),^{completion(json,error);}); }] resume];
}
- (UITextField *)field { return [self.controller valueForKey:@"keyField"]; }
- (UIButton *)button { return [self.controller valueForKey:@"loginButton"]; }
- (UILabel *)statusLabel { return [self.controller valueForKey:@"loginStatusLabel"]; }
- (void)setStatus:(NSString *)text { UILabel *label=[self statusLabel]; label.text=text; label.textColor=[UIColor whiteColor]; label.numberOfLines=0; }
- (void)finishLogin:(NSString *)code {
  @try {
    [self.controller setValue:code forKey:@"accountLicenseKey"];
    [self.controller setValue:@YES forKey:@"accountKeyVisible"];
    [self.controller performSelector:NSSelectorFromString(@"showDashboardPage")];
  } @catch (__unused NSException *e) {}
  UIView *loginView=nil; @try { loginView=[self.controller valueForKey:@"loginView"]; } @catch (__unused NSException *e) {}
  loginView.hidden=YES;
}
- (void)activate:(id)sender {
  NSString *code=[[[self field] text] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]; NSString *pub=[self publicKeyPEM];
  if(!code.length||!pub.length){[self setStatus:@"Insira uma key SLEEP- válida."];return;}
  [self button].enabled=NO; [self setStatus:@"Verificando key SLEEP STORE…"];
  NSDictionary *body=@{@"key":code,@"installationId":pub,@"deviceName":UIDevice.currentDevice.name,@"appVersion":NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]?:@"unknown"};
  __weak typeof(self) weakSelf=self;
  [self post:body path:@"/api/license/activate" completion:^(NSDictionary *json,NSError *error){ __strong typeof(weakSelf) self=weakSelf; [self button].enabled=YES; NSString *s=[json[@"status"] isKindOfClass:NSString.class]?json[@"status"]:@"invalid"; if(error){[self setStatus:@"Não foi possível conectar ao servidor. Tente novamente."];return;} if(![s isEqualToString:@"active"]){NSDictionary *m=@{@"invalid":@"Key inválida ou inexistente.",@"expired":@"Esta key expirou.",@"disabled":@"Esta key está bloqueada.",@"revoked":@"Esta key foi revogada.",@"device_mismatch":@"Esta key já está vinculada a outro dispositivo.",@"rate_limited":@"Servidor ocupado. Tente novamente em alguns instantes."}; [self setStatus:m[s]?:@"Não foi possível ativar a licença."];return;} NSData *d=[code dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary *item=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag,(__bridge id)kSecValueData:d,(__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly}; SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag}); SecItemAdd((__bridge CFDictionaryRef)item,NULL); [self finishLogin:code]; }];
}
- (void)prepare:(UIViewController *)controller {
  self.controller=controller; [self ensureDeviceKey];
  UIView *loginView=nil; @try { loginView=[controller valueForKey:@"loginView"]; } @catch (__unused NSException *e) {}
  loginView.backgroundColor=[UIColor clearColor];
  UITextField *field=[self field]; field.placeholder=@"SLEEP- key"; field.textColor=[UIColor whiteColor]; field.tintColor=[UIColor whiteColor]; field.backgroundColor=[UIColor colorWithWhite:0 alpha:.35]; field.autocapitalizationType=UITextAutocapitalizationTypeNone; field.autocorrectionType=UITextAutocorrectionTypeNo;
  UIButton *button=[self button]; [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside]; [button setTitle:@"Ativar SLEEP STORE" forState:UIControlStateNormal]; [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; button.backgroundColor=[UIColor colorWithWhite:0 alpha:.55]; [button addTarget:self action:@selector(activate:) forControlEvents:UIControlEventTouchUpInside];
  [self setStatus:@"sleepffx · dev|cholyyk"]; 
}
@end

static NSMapTable *SleepBridges;
static void (*SleepOriginalViewDidAppear)(id,SEL,BOOL);
static void SleepPatchedViewDidAppear(id self, SEL cmd, BOOL animated) {
  if(SleepOriginalViewDidAppear) SleepOriginalViewDidAppear(self,cmd,animated);
  dispatch_async(dispatch_get_main_queue(),^{
    if(!SleepBridges) SleepBridges=[NSMapTable weakToStrongObjectsMapTable];
    SleepNativeBridge *bridge=[SleepBridges objectForKey:self]; if(!bridge){bridge=[SleepNativeBridge new]; [SleepBridges setObject:bridge forKey:self];}
    [bridge prepare:self];
  });
}
__attribute__((constructor)) static void SleepInstall(void){ dispatch_async(dispatch_get_main_queue(),^{ Class c=objc_getClass("ViewController"); Method m=c?class_getInstanceMethod(c,@selector(viewDidAppear:)):NULL; if(!m)return; SleepOriginalViewDidAppear=(void(*)(id,SEL,BOOL))method_getImplementation(m); method_setImplementation(m,(IMP)SleepPatchedViewDidAppear); }); }
