// LoginViewController.m
// Referência para integrar na FilzaApplySandboxExt. Ajuste API_BASE_URL e o ponto
// de apresentação ao controlador raiz real do Filza.
#import <UIKit/UIKit.h>
#import <Security/Security.h>

// Defina o domínio publicado do painel SLEEP Control antes de compilar a tweak.
static NSString * const API_BASE_URL = @"https://sleeppanel-by9jc9qe.manus.space";
static NSString * const KeychainTag = @"com.filzaslop.device-key";
static NSString * const KeychainToken = @"com.filzaslop.device-token";

@interface LoginViewController : UIViewController
@end

@interface LoginViewController ()
@property(nonatomic,strong) UITextField *codeField;
@property(nonatomic,strong) UILabel *messageLabel;
@property(nonatomic,strong) UIButton *continueButton;
@property(nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic,strong) UIButton *discordButton;
@property(nonatomic,strong) UILabel *eyebrowLabel;
@property(nonatomic,assign) SecKeyRef privateKey;
@end

@implementation LoginViewController

- (void)dealloc { if (self.privateKey) CFRelease(self.privateKey); }

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithRed:0.035 green:0.039 blue:0.055 alpha:1];
  self.title = @"";
  self.navigationController.navigationBarHidden = YES;

  UIView *card = [[UIView alloc] initWithFrame:CGRectZero];
  card.backgroundColor = [UIColor colorWithRed:0.075 green:0.082 blue:0.12 alpha:1];
  card.layer.cornerRadius = 24;
  card.layer.borderWidth = 1;
  card.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.10].CGColor;
  card.translatesAutoresizingMaskIntoConstraints = NO;

  self.eyebrowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.eyebrowLabel.text = @"SLEEP STORE";
  self.eyebrowLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
  self.eyebrowLabel.textColor = [UIColor colorWithRed:0.62 green:0.52 blue:1 alpha:1];
  self.eyebrowLabel.translatesAutoresizingMaskIntoConstraints = NO;

  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  titleLabel.text = @"Ativar dispositivo";
  titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
  titleLabel.textColor = UIColor.whiteColor;
  titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

  self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.messageLabel.numberOfLines = 0;
  self.messageLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
  self.messageLabel.textColor = [UIColor colorWithWhite:0.70 alpha:1];
  self.messageLabel.text = @"sleepffx · dev|cholyyk\nInsira sua key para vincular este dispositivo com segurança.";
  self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

  self.codeField = [[UITextField alloc] initWithFrame:CGRectZero];
  self.codeField.placeholder = @"SLEEP- key";
  self.codeField.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightMedium];
  self.codeField.textColor = UIColor.whiteColor;
  self.codeField.tintColor = [UIColor colorWithRed:0.62 green:0.52 blue:1 alpha:1];
  self.codeField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  self.codeField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.codeField.keyboardType = UIKeyboardTypeASCIICapable;
  self.codeField.backgroundColor = [UIColor colorWithWhite:0 alpha:0.28];
  self.codeField.layer.cornerRadius = 14;
  self.codeField.layer.borderWidth = 1;
  self.codeField.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.10].CGColor;
  self.codeField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 1)];
  self.codeField.leftViewMode = UITextFieldViewModeAlways;
  self.codeField.translatesAutoresizingMaskIntoConstraints = NO;

  self.continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.continueButton setTitle:@"Ativar dispositivo" forState:UIControlStateNormal];
  self.continueButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
  self.continueButton.backgroundColor = [UIColor colorWithRed:0.40 green:0.28 blue:0.95 alpha:1];
  [self.continueButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  self.continueButton.layer.cornerRadius = 14;
  self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.continueButton addTarget:self action:@selector(activate:) forControlEvents:UIControlEventTouchUpInside];

  self.discordButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.discordButton setTitle:@"Discord · sleepffx" forState:UIControlStateNormal];
  [self.discordButton setTitleColor:[UIColor colorWithWhite:0.76 alpha:0.95] forState:UIControlStateNormal];
  self.discordButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
  self.discordButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.discordButton addTarget:self action:@selector(openDiscord:) forControlEvents:UIControlEventTouchUpInside];

  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
  self.activityIndicator.color = UIColor.whiteColor;
  self.activityIndicator.hidesWhenStopped = YES;
  self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

  [self.view addSubview:card];
  [self.view addSubview:self.discordButton];
  [card addSubview:self.eyebrowLabel]; [card addSubview:titleLabel]; [card addSubview:self.messageLabel]; [card addSubview:self.codeField]; [card addSubview:self.continueButton]; [card addSubview:self.activityIndicator];
  [NSLayoutConstraint activateConstraints:@[
    [card.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20], [card.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20], [card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    [self.eyebrowLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24], [self.eyebrowLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:26],
    [titleLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24], [titleLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24], [titleLabel.topAnchor constraintEqualToAnchor:self.eyebrowLabel.bottomAnchor constant:8],
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24], [self.messageLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24], [self.messageLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:10],
    [self.codeField.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24], [self.codeField.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24], [self.codeField.topAnchor constraintEqualToAnchor:self.messageLabel.bottomAnchor constant:24], [self.codeField.heightAnchor constraintEqualToConstant:54],
    [self.continueButton.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24], [self.continueButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24], [self.continueButton.topAnchor constraintEqualToAnchor:self.codeField.bottomAnchor constant:14], [self.continueButton.heightAnchor constraintEqualToConstant:52], [self.continueButton.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-24],
    [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.continueButton.centerXAnchor], [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.continueButton.centerYAnchor],
    [self.discordButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor], [self.discordButton.topAnchor constraintEqualToAnchor:card.bottomAnchor constant:10], [self.discordButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10], [self.discordButton.heightAnchor constraintEqualToConstant:28]
  ]];
  [self ensureDeviceKey];
  [self validateStoredToken];
}

- (void)validateStoredToken {
  NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount:KeychainToken, (__bridge id)kSecReturnData:@YES}; CFTypeRef ref = NULL;
  if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &ref) != errSecSuccess) return;
  NSData *data = CFBridgingRelease(ref); NSString *code = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; if (!code.length) return;
  [self postJSON:@{ @"key":code, @"installationId":[self publicKeyPEM] ?: @"", @"deviceName":UIDevice.currentDevice.name, @"appVersion":NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: @"unknown" } path:@"/api/license/validate" completion:^(NSDictionary *json, NSError *error) {
    NSString *status = [json[@"status"] isKindOfClass:NSString.class] ? json[@"status"] : @"invalid";
    dispatch_async(dispatch_get_main_queue(), ^{ if (!error && [status isEqualToString:@"active"]) [self dismissViewControllerAnimated:NO completion:nil]; else { SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount:KeychainToken}); self.messageLabel.text = @"Esta ativação não está mais válida. Informe uma nova key."; } });
  }];
}

- (void)ensureDeviceKey {
  NSData *tag = [KeychainTag dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassKey, (__bridge id)kSecAttrApplicationTag:tag, (__bridge id)kSecReturnRef:@YES};
  SecKeyRef existing = NULL;
  if (SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&existing) == errSecSuccess) { self.privateKey = existing; return; }
  NSDictionary *attrs = @{(__bridge id)kSecAttrKeyType:(__bridge id)kSecAttrKeyTypeECSECPrimeRandom, (__bridge id)kSecAttrKeySizeInBits:@256, (__bridge id)kSecPrivateKeyAttrs:@{(__bridge id)kSecAttrIsPermanent:@YES, (__bridge id)kSecAttrApplicationTag:tag}};
  CFErrorRef error = NULL;
  self.privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attrs, &error);
  if (error) CFRelease(error);
}

- (NSString *)publicKeyPEM {
  SecKeyRef pub = SecKeyCopyPublicKey(self.privateKey); CFErrorRef error = NULL;
  CFDataRef data = SecKeyCopyExternalRepresentation(pub, &error); if (pub) CFRelease(pub); if (!data) { if (error) CFRelease(error); return nil; }
  NSString *b64 = [(__bridge NSData *)data base64EncodedStringWithOptions:0]; CFRelease(data);
  return [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----", b64];
}

- (void)postJSON:(NSDictionary *)body path:(NSString *)path completion:(void (^)(NSDictionary *, NSError *))completion {
  NSURL *url = [NSURL URLWithString:[API_BASE_URL stringByAppendingString:path]]; NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; request.HTTPMethod = @"POST"; [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
  [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { NSDictionary *json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil; dispatch_async(dispatch_get_main_queue(), ^{ completion(json, error ?: ([json[@"error"] isKindOfClass:NSString.class] ? [NSError errorWithDomain:@"FilzaAuth" code:1 userInfo:@{NSLocalizedDescriptionKey:json[@"error"]}] : nil)); }); }] resume];
}

- (void)openDiscord:(id)sender {
  NSURL *url = [NSURL URLWithString:@"https://discord.gg/sleepff"];
  [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)activate:(id)sender {
  NSString *code = [self.codeField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]; NSString *pub = [self publicKeyPEM]; if (!code.length || !pub.length) { self.messageLabel.text = @"Informe uma key válida."; return; }
  self.continueButton.enabled = NO; [self.activityIndicator startAnimating]; self.continueButton.alpha = 0.72; [self postJSON:@{ @"key":code, @"installationId":pub, @"deviceName":UIDevice.currentDevice.name, @"appVersion":NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: @"unknown" } path:@"/api/license/activate" completion:^(NSDictionary *json, NSError *error) {
    NSString *status = [json[@"status"] isKindOfClass:NSString.class] ? json[@"status"] : @"invalid";
    self.continueButton.enabled = YES; self.continueButton.alpha = 1.0; [self.activityIndicator stopAnimating];
    if (error || ![status isEqualToString:@"active"]) { NSDictionary *messages = @{ @"invalid":@"Key inválida ou inexistente.", @"expired":@"Esta key expirou.", @"disabled":@"Esta key está bloqueada.", @"revoked":@"Esta key foi revogada.", @"device_mismatch":@"Esta key já está vinculada a outro dispositivo.", @"rate_limited":@"Muitas tentativas. Tente novamente mais tarde." }; self.messageLabel.text = messages[status] ?: @"Não foi possível ativar a licença."; return; }
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary *item = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount:KeychainToken, (__bridge id)kSecValueData:codeData, (__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly}; SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount:KeychainToken}); SecItemAdd((__bridge CFDictionaryRef)item, NULL);
    [self dismissViewControllerAnimated:YES completion:nil];
  }];
}
@end
