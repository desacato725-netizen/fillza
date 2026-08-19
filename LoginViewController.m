// LoginViewController.m
// Referência para integrar na FilzaApplySandboxExt. Ajuste API_BASE_URL e o ponto
// de apresentação ao controlador raiz real do Filza.
#import <UIKit/UIKit.h>
#import <Security/Security.h>

static NSString * const API_BASE_URL = @"https://SEU-DOMINIO.example.com";
static NSString * const KeychainTag = @"com.filzaslop.device-key";
static NSString * const KeychainToken = @"com.filzaslop.device-token";

@interface LoginViewController : UIViewController
@end

@interface LoginViewController ()
@property(nonatomic,strong) UITextField *codeField;
@property(nonatomic,strong) UILabel *messageLabel;
@property(nonatomic,strong) UIButton *continueButton;
@property(nonatomic,strong) SecKeyRef privateKey;
@end

@implementation LoginViewController

- (void)dealloc { if (_privateKey) CFRelease(_privateKey); }

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.99 alpha:1];
  self.title = @"Ativar Filza";
  self.codeField = [[UITextField alloc] initWithFrame:CGRectZero];
  self.codeField.placeholder = @"Código de ativação";
  self.codeField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
  self.codeField.borderStyle = UITextBorderStyleRoundedRect;
  self.codeField.translatesAutoresizingMaskIntoConstraints = NO;
  self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.messageLabel.numberOfLines = 0;
  self.messageLabel.textColor = [UIColor secondaryLabelColor];
  self.messageLabel.textAlignment = NSTextAlignmentCenter;
  self.messageLabel.text = @"Insira o código fornecido pelo administrador. Este dispositivo será vinculado uma única vez.";
  self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [self.continueButton setTitle:@"Ativar dispositivo" forState:UIControlStateNormal];
  self.continueButton.backgroundColor = [UIColor colorWithRed:0.19 green:0.23 blue:0.82 alpha:1];
  [self.continueButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
  self.continueButton.layer.cornerRadius = 12;
  self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.continueButton addTarget:self action:@selector(activate:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.messageLabel]; [self.view addSubview:self.codeField]; [self.view addSubview:self.continueButton];
  [NSLayoutConstraint activateConstraints:@[
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32], [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32], [self.messageLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-90],
    [self.codeField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32], [self.codeField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32], [self.codeField.topAnchor constraintEqualToAnchor:self.messageLabel.bottomAnchor constant:24], [self.codeField.heightAnchor constraintEqualToConstant:50],
    [self.continueButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32], [self.continueButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32], [self.continueButton.topAnchor constraintEqualToAnchor:self.codeField.bottomAnchor constant:14], [self.continueButton.heightAnchor constraintEqualToConstant:50]
  ]];
  [self ensureDeviceKey];
  [self validateStoredToken];
}

- (void)validateStoredToken {
  NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount:KeychainToken, (__bridge id)kSecReturnData:@YES}; CFTypeRef ref = NULL;
  if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &ref) != errSecSuccess) return;
  NSData *data = CFBridgingRelease(ref); NSString *token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; if (!token.length) return;
  NSURL *url = [NSURL URLWithString:[API_BASE_URL stringByAppendingString:@"/api/device/validate"]]; NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; request.HTTPMethod = @"POST"; [request setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
  [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error) { BOOL valid = NO; if (!error && responseData) { NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil]; valid = [json[@"valid"] boolValue]; } dispatch_async(dispatch_get_main_queue(), ^{ if (valid) [self dismissViewControllerAnimated:NO completion:nil]; else { SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount:KeychainToken}); self.messageLabel.text = @"Esta ativação não está mais válida. Informe um novo código."; } }); }] resume];
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

- (void)activate:(id)sender {
  NSString *code = [self.codeField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]; NSString *pub = [self publicKeyPEM]; if (!code.length || !pub.length) { self.messageLabel.text = @"Informe um código válido."; return; }
  self.continueButton.enabled = NO; [self postJSON:@{ @"activationCode":code, @"publicKey":pub, @"deviceName":UIDevice.currentDevice.name, @"appVersion":NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: @"unknown" } path:@"/api/device/activate" completion:^(NSDictionary *json, NSError *error) {
    if (error) { self.continueButton.enabled = YES; self.messageLabel.text = error.localizedDescription; return; }
    [self requestChallenge];
  }];
}

- (void)requestChallenge {
  [self postJSON:@{ @"publicKey": [self publicKeyPEM] } path:@"/api/device/auth" completion:^(NSDictionary *json, NSError *error) {
    if (error) { self.continueButton.enabled = YES; self.messageLabel.text = error.localizedDescription; return; }
    NSString *challenge = json[@"challenge"]; NSData *message = [challenge dataUsingEncoding:NSUTF8StringEncoding]; CFErrorRef signingError = NULL; CFDataRef sig = SecKeyCreateSignature(self.privateKey, kSecKeyAlgorithmECDSASignatureMessageX962SHA256, (__bridge CFDataRef)message, &signingError); if (!sig) { self.messageLabel.text = @"Não foi possível assinar o desafio."; self.continueButton.enabled = YES; if (signingError) CFRelease(signingError); return; }
    NSString *signature = [(__bridge NSData *)sig base64EncodedStringWithOptions:0]; CFRelease(sig);
    [self postJSON:@{ @"publicKey":[self publicKeyPEM], @"challenge":challenge, @"signature":signature } path:@"/api/device/auth" completion:^(NSDictionary *auth, NSError *authError) {
      self.continueButton.enabled = YES; if (authError) { self.messageLabel.text = authError.localizedDescription; return; }
      NSData *tokenData = [auth[@"token"] dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary *item = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount:KeychainToken, (__bridge id)kSecValueData:tokenData, (__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly}; SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrAccount:KeychainToken}); SecItemAdd((__bridge CFDictionaryRef)item, NULL);
      [self dismissViewControllerAnimated:YES completion:nil];
    }];
  }];
}
@end
