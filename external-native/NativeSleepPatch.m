#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <objc/runtime.h>

static NSString * const SleepAPI = @"https://sleeppanel-by9jc9qe.manus.space";
static NSString * const SleepKeyTag = @"com.filzaslop.device-key";
static NSString * const SleepTokenTag = @"com.filzaslop.device-token";
static NSString * const SleepInstallMarker = @"com.filzaslop.installation-marker";
static NSString * const SleepBranding = @"sleepffx · dev|cholyyk";
__attribute__((used)) static const char SleepBrandingMarker[] = "sleepffx";
static NSString * const SleepDiscord = @"https://discord.gg/sleepff";

@interface SleepDiscordTarget : NSObject
@end
@implementation SleepDiscordTarget
- (void)openDiscord:(id)sender { [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SleepDiscord] options:@{} completionHandler:nil]; }
@end
@interface SleepNativeBridge : NSObject
@property(nonatomic,weak) UIViewController *controller;
@property(nonatomic,assign) SecKeyRef privateKey;
@property(nonatomic,assign) BOOL activationInFlight;
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
  NSURL *url=[NSURL URLWithString:[SleepAPI stringByAppendingString:path]]; NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url]; request.HTTPMethod=@"POST"; request.timeoutInterval=20.0; [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; request.HTTPBody=[NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
  [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){ NSError *finalError=error; NSHTTPURLResponse *http=[response isKindOfClass:NSHTTPURLResponse.class]?(NSHTTPURLResponse *)response:nil; if(!finalError && (!http || http.statusCode<200 || http.statusCode>=300)) finalError=[NSError errorWithDomain:@"SleepStoreHTTP" code:(http ? http.statusCode : -1) userInfo:nil]; NSDictionary *json=@{}; if(data.length){ id parsed=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; if([parsed isKindOfClass:NSDictionary.class]) json=parsed; else if(!finalError) finalError=[NSError errorWithDomain:@"SleepStoreJSON" code:-1 userInfo:nil]; } else if(!finalError) finalError=[NSError errorWithDomain:@"SleepStoreEmptyResponse" code:-1 userInfo:nil]; dispatch_async(dispatch_get_main_queue(),^{ completion(json,finalError); }); }] resume];
}
- (void)saveKey:(NSString *)code { NSData *data=[code dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary *item=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag,(__bridge id)kSecValueData:data,(__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly}; SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag}); SecItemAdd((__bridge CFDictionaryRef)item,NULL); }
- (void)validateStoredToken {
  NSDictionary *query=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag,(__bridge id)kSecReturnData:@YES}; CFTypeRef ref=NULL; if(SecItemCopyMatching((__bridge CFDictionaryRef)query,&ref)!=errSecSuccess)return;
  NSData *data=CFBridgingRelease(ref); NSString *code=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; NSString *pub=[self publicKeyPEM]; if(!code.length||!pub.length)return;
  NSDictionary *body=@{@"key":code,@"installationId":pub,@"deviceName":UIDevice.currentDevice.name,@"appVersion":NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]?:@"unknown"};
  [self post:body path:@"/api/license/validate" completion:^(NSDictionary *json,NSError *error){ NSString *status=[json[@"status"] isKindOfClass:NSString.class]?json[@"status"]:@"invalid"; if(error||[status isEqualToString:@"rate_limited"]){return;} if([status isEqualToString:@"active"]){return;} SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:SleepTokenTag}); }];
}
- (void)showOriginalDashboard {
  BOOL dashboardShown=NO;
  @try { [self.controller performSelector:NSSelectorFromString(@"showDashboardPage")]; dashboardShown=YES; } @catch (__unused NSException *e) {}
  if(!dashboardShown){ [self setStatus:@"Key validada, mas o dashboard original não pôde ser aberto."]; return; }
  @try { [self.controller setValue:[[[self.controller valueForKey:@"keyField"] text] copy] forKey:@"accountLicenseKey"]; } @catch (__unused NSException *e) {}
  @try { [self.controller setValue:@YES forKey:@"accountKeyVisible"]; } @catch (__unused NSException *e) {}
}
- (void)activate {
  UITextField *field=nil; @try { field=[self.controller valueForKey:@"keyField"]; } @catch (__unused NSException *e) {}
  NSString *rawCode = field.text ?: @""; NSString *code=[rawCode stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]; NSString *pub=[self publicKeyPEM];
  if(!code.length||![code hasPrefix:@"SLEEP-"]||!pub.length){[self setStatus:@"Informe uma key SLEEP- válida."];return;}
  UIButton *button=nil; @try { button=[self.controller valueForKey:@"loginButton"]; } @catch (__unused NSException *e) {} button.enabled=NO; self.activationInFlight=YES; [self setStatus:@"Verificando key SLEEP STORE…"];
  NSDictionary *body=@{@"key":code,@"installationId":pub,@"deviceName":UIDevice.currentDevice.name,@"appVersion":NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]?:@"unknown"}; __weak typeof(self) weakSelf=self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(22.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ __strong typeof(weakSelf) self=weakSelf; if(!self || !self.activationInFlight)return; self.activationInFlight=NO; button.enabled=YES; [self setStatus:@"Tempo limite ao conectar ao servidor. Tente novamente."]; });
  [self post:body path:@"/api/license/activate" completion:^(NSDictionary *json,NSError *error){ __strong typeof(weakSelf) self=weakSelf; if(!self || !self.activationInFlight)return; self.activationInFlight=NO; button.enabled=YES; NSString *status=[json[@"status"] isKindOfClass:NSString.class]?json[@"status"]:@"invalid"; if(error){[self setStatus:@"Não foi possível conectar ao servidor. Tente novamente."];return;} if(![status isEqualToString:@"active"]){NSDictionary *messages=@{@"invalid":@"Key inválida ou inexistente.",@"expired":@"Esta key expirou.",@"disabled":@"Esta key está bloqueada.",@"revoked":@"Esta key foi revogada.",@"device_mismatch":@"Esta key já está vinculada a outro dispositivo.",@"rate_limited":@"Servidor ocupado. Tente novamente em instantes."}; [self setStatus:messages[status]?:@"Não foi possível ativar a licença."];return;} [self saveKey:code]; [self showOriginalDashboard]; }];
}
- (void)openDiscord:(id)sender { [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SleepDiscord] options:@{} completionHandler:nil]; }
@end

static NSMapTable *SleepBridges;
static void (*SleepOriginalViewDidAppear)(id, SEL, BOOL);
static void SleepInstallLoginWatermark(id controller) {
  UIView *root=nil; UITextField *field=nil; UIButton *loginButton=nil;
  @try { root=[controller valueForKey:@"view"]; field=[controller valueForKey:@"keyField"]; loginButton=[controller valueForKey:@"loginButton"]; } @catch (__unused NSException *e) { return; }
  if(!root || !field || !loginButton || [root viewWithTag:7788]) return;
  UILabel *signature=[[UILabel alloc] initWithFrame:CGRectZero]; signature.tag=7788; signature.text=@"dev|cholyyk"; signature.textColor=[UIColor colorWithWhite:0.88 alpha:0.92]; signature.font=[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]; signature.textAlignment=NSTextAlignmentCenter; signature.translatesAutoresizingMaskIntoConstraints=NO;
  UIButton *discord=[UIButton buttonWithType:UIButtonTypeSystem]; discord.tag=7789; [discord setTitle:@"Discord · sleepffx" forState:UIControlStateNormal]; discord.titleLabel.font=[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]; [discord setTitleColor:[UIColor colorWithWhite:0.76 alpha:0.95] forState:UIControlStateNormal]; discord.translatesAutoresizingMaskIntoConstraints=NO; [discord addTarget:[SleepDiscordTarget new] action:@selector(openDiscord:) forControlEvents:UIControlEventTouchUpInside];
  [root addSubview:signature]; [root addSubview:discord];
  [NSLayoutConstraint activateConstraints:@[[signature.centerXAnchor constraintEqualToAnchor:root.centerXAnchor],[signature.bottomAnchor constraintEqualToAnchor:discord.topAnchor constant:-2],[discord.centerXAnchor constraintEqualToAnchor:root.centerXAnchor],[discord.bottomAnchor constraintEqualToAnchor:root.safeAreaLayoutGuide.bottomAnchor constant:-10],[discord.heightAnchor constraintEqualToConstant:26]]];
}
static void SleepPatchedViewDidAppear(id self, SEL cmd, BOOL animated) {
  if(SleepOriginalViewDidAppear) SleepOriginalViewDidAppear(self,cmd,animated);
  dispatch_async(dispatch_get_main_queue(), ^{ SleepInstallLoginWatermark(self); });
}
static void SleepActivateForController(id controller) {
  (void)SleepBrandingMarker;
  if(!SleepBridges) SleepBridges=[NSMapTable weakToStrongObjectsMapTable];
  SleepNativeBridge *bridge=[SleepBridges objectForKey:controller]; if(!bridge){bridge=[SleepNativeBridge new]; bridge.controller=controller; [SleepBridges setObject:bridge forKey:controller]; [bridge prepareInstallationState]; [bridge ensureDeviceKey]; [bridge validateStoredToken]; [bridge setStatus:@"dev|cholyyk"];}
  [bridge activate];
}
static void SleepPatchedLoginTappedNoArg(id self, SEL cmd) { SleepActivateForController(self); }
static void SleepPatchedLoginTappedWithSender(id self, SEL cmd, id sender) { SleepActivateForController(self); }
__attribute__((constructor)) static void SleepInstall(void) {
  dispatch_async(dispatch_get_main_queue(), ^{
    Class cls=objc_getClass("ViewController"); if(!cls)return;
    SEL noArg=NSSelectorFromString(@"loginTapped"); Method method=class_getInstanceMethod(cls,noArg);
    if(method){ const char *types=method_getTypeEncoding(method); if(!class_addMethod(cls,noArg,(IMP)SleepPatchedLoginTappedNoArg,types)) method_setImplementation(method,(IMP)SleepPatchedLoginTappedNoArg); }
    SEL withSender=NSSelectorFromString(@"loginTapped:"); method=class_getInstanceMethod(cls,withSender); if(method){ const char *types=method_getTypeEncoding(method); if(!class_addMethod(cls,withSender,(IMP)SleepPatchedLoginTappedWithSender,types)) method_setImplementation(method,(IMP)SleepPatchedLoginTappedWithSender); }
    SEL appear=NSSelectorFromString(@"viewDidAppear:"); Method appearMethod=class_getInstanceMethod(cls,appear); if(appearMethod){ SleepOriginalViewDidAppear=(void(*)(id,SEL,BOOL))method_getImplementation(appearMethod); const char *appearTypes=method_getTypeEncoding(appearMethod); if(!class_addMethod(cls,appear,(IMP)SleepPatchedViewDidAppear,appearTypes)) method_setImplementation(appearMethod,(IMP)SleepPatchedViewDidAppear); }
  });
}
