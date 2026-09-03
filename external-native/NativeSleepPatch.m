#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <objc/runtime.h>

static NSString * const SleepAPI = @"https://sleeppanel-by9jc9qe.manus.space";
static NSString * const SleepKeyTag = @"com.filzaslop.device-key";
static NSString * const SleepTokenTag = @"com.filzaslop.device-token";
static NSString * const SleepInstallMarker = @"com.filzaslop.installation-marker";
static NSString * const SleepBranding = @"sleepffx · dev|cholyyk";
static NSString * const SleepDiscord = @"https://discord.gg/sleepff";

@interface SleepNativeBridge : NSObject
@property(nonatomic,weak) UIViewController *controller;
@property(nonatomic,assign) SecKeyRef privateKey;
@end

@implementation SleepNativeBridge
- (void)dealloc { if (self.privateKey) CFRelease(self.privateKey); }
- (void)prepareInstallationState {
  NSUserDefaults *defaults=NSUserDefaults.standardUserDefaults;
  if([defaults boolForKey:SleepInstallMarker]) return;
  NSDictionary *token=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag};
  SecItemDelete((__bridge CFDictionaryRef)token);
  NSDictionary *key=@{(__bridge id)kSecClass:(__bridge id)kSecClassKey,(__bridge id)kSecAttrApplicationTag:[SleepKeyTag dataUsingEncoding:NSUTF8StringEncoding]};
  SecItemDelete((__bridge CFDictionaryRef)key);
  [defaults setBool:YES forKey:SleepInstallMarker]; [defaults synchronize];
}
- (void)ensureDeviceKey {
  NSData *tag=[SleepKeyTag dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *query=@{(__bridge id)kSecClass:(__bridge id)kSecClassKey,(__bridge id)kSecAttrApplicationTag:tag,(__bridge id)kSecReturnRef:@YES};
  SecKeyRef existing=NULL;
  if(SecItemCopyMatching((__bridge CFDictionaryRef)query,(CFTypeRef *)&existing)==errSecSuccess){self.privateKey=existing;return;}
  NSDictionary *attrs=@{(__bridge id)kSecAttrKeyType:(__bridge id)kSecAttrKeyTypeECSECPrimeRandom,(__bridge id)kSecAttrKeySizeInBits:@256,(__bridge id)kSecPrivateKeyAttrs:@{(__bridge id)kSecAttrIsPermanent:@YES,(__bridge id)kSecAttrApplicationTag:tag}};
  CFErrorRef error=NULL; self.privateKey=SecKeyCreateRandomKey((__bridge CFDictionaryRef)attrs,&error); if(error)CFRelease(error);
}
- (NSString *)publicKeyPEM {
  if(!self.privateKey)return nil; SecKeyRef pub=SecKeyCopyPublicKey(self.privateKey); CFErrorRef error=NULL; CFDataRef raw=SecKeyCopyExternalRepresentation(pub,&error); if(pub)CFRelease(pub); if(!raw){if(error)CFRelease(error);return nil;}
  NSString *b64=[(__bridge NSData *)raw base64EncodedStringWithOptions:0]; CFRelease(raw); return [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----",b64];
}
- (void)setStatus:(NSString *)text {
  @try { UILabel *label=[self.controller valueForKey:@"loginStatusLabel"]; label.text=text; label.numberOfLines=0; } @catch (__unused NSException *e) {}
}
- (void)post:(NSDictionary *)body path:(NSString *)path completion:(void (^)(NSDictionary *,NSError *))completion {
  NSURL *url=[NSURL URLWithString:[SleepAPI stringByAppendingString:path]]; NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url]; request.HTTPMethod=@"POST"; [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; request.HTTPBody=[NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
  [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){ NSDictionary *json=data?[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]:@{}; dispatch_async(dispatch_get_main_queue(),^{ completion(json,error); }); }] resume];
}
- (void)saveKey:(NSString *)code { NSData *data=[code dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary *item=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag,(__bridge id)kSecValueData:data,(__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly}; SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag}); SecItemAdd((__bridge CFDictionaryRef)item,NULL); }
- (void)showOriginalDashboard {
  @try { [self.controller setValue:[[[self.controller valueForKey:@"keyField"] text] copy] forKey:@"accountLicenseKey"]; [self.controller setValue:@YES forKey:@"accountKeyVisible"]; [self.controller performSelector:NSSelectorFromString(@"showDashboardPage")]; } @catch (__unused NSException *e) {}
}
- (void)activate {
  UITextField *field=nil; @try { field=[self.controller valueForKey:@"keyField"]; } @catch (__unused NSException *e) {}
  NSString *code=[[field.text ?: @""] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]; NSString *pub=[self publicKeyPEM];
  if(!code.length||![code hasPrefix:@"SLEEP-"]||!pub.length){[self setStatus:@"Informe uma key SLEEP- válida."];return;}
  UIButton *button=nil; @try { button=[self.controller valueForKey:@"loginButton"]; } @catch (__unused NSException *e) {} button.enabled=NO; [self setStatus:@"Verificando key SLEEP STORE…"];
  NSDictionary *body=@{@"key":code,@"installationId":pub,@"deviceName":UIDevice.currentDevice.name,@"appVersion":NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]?:@"unknown"}; __weak typeof(self) weakSelf=self;
  [self post:body path:@"/api/license/activate" completion:^(NSDictionary *json,NSError *error){ __strong typeof(weakSelf) self=weakSelf; button.enabled=YES; NSString *status=[json[@"status"] isKindOfClass:NSString.class]?json[@"status"]:@"invalid"; if(error){[self setStatus:@"Não foi possível conectar ao servidor. Tente novamente."];return;} if(![status isEqualToString:@"active"]){NSDictionary *messages=@{@"invalid":@"Key inválida ou inexistente.",@"expired":@"Esta key expirou.",@"disabled":@"Esta key está bloqueada.",@"revoked":@"Esta key foi revogada.",@"device_mismatch":@"Esta key já está vinculada a outro dispositivo.",@"rate_limited":@"Servidor ocupado. Tente novamente em instantes."}; [self setStatus:messages[status]?:@"Não foi possível ativar a licença."];return;} [self saveKey:code]; [self showOriginalDashboard]; }];
}
- (void)openDiscord:(id)sender { [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SleepDiscord] options:@{} completionHandler:nil]; }
@end

static NSMapTable *SleepBridges;
static void SleepActivateForController(id controller) {
  if(!SleepBridges) SleepBridges=[NSMapTable weakToStrongObjectsMapTable];
  SleepNativeBridge *bridge=[SleepBridges objectForKey:controller]; if(!bridge){bridge=[SleepNativeBridge new]; bridge.controller=controller; [SleepBridges setObject:bridge forKey:controller]; [bridge prepareInstallationState]; [bridge ensureDeviceKey]; [bridge setStatus:@"dev|cholyyk"];}
  [bridge activate];
}
static void SleepPatchedLoginTappedNoArg(id self, SEL cmd) { SleepActivateForController(self); }
static void SleepPatchedLoginTappedWithSender(id self, SEL cmd, id sender) { SleepActivateForController(self); }
__attribute__((constructor)) static void SleepInstall(void) {
  dispatch_async(dispatch_get_main_queue(), ^{
    Class cls=objc_getClass("ViewController"); if(!cls)return;
    SEL noArg=NSSelectorFromString(@"loginTapped"); Method method=class_getInstanceMethod(cls,noArg);
    if(method){ const char *types=method_getTypeEncoding(method); if(!class_addMethod(cls,noArg,(IMP)SleepPatchedLoginTappedNoArg,types)) method_setImplementation(method,(IMP)SleepPatchedLoginTappedNoArg); return; }
    SEL withSender=NSSelectorFromString(@"loginTapped:"); method=class_getInstanceMethod(cls,withSender); if(!method)return; const char *types=method_getTypeEncoding(method); if(!class_addMethod(cls,withSender,(IMP)SleepPatchedLoginTappedWithSender,types)) method_setImplementation(method,(IMP)SleepPatchedLoginTappedWithSender);
  });
}
