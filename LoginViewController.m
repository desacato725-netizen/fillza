// LoginViewController.m


#import <UIKit/UIKit.h>


#import <Security/Security.h>


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


@property(nonatomic,assign) SecKeyRef privateKey;


@end


@implementation LoginViewController


- (void)dealloc { if (self.privateKey) CFRelease(self.privateKey); }


- (void)viewDidLoad {


 [super viewDidLoad]; self.view.backgroundColor=[UIColor colorWithRed:.035 green:.039 blue:.055 alpha:1]; self.navigationController.navigationBarHidden=YES;
 
 UIView *card=[[UIView alloc] initWithFrame:CGRectZero]; card.backgroundColor=[UIColor colorWithRed:.075 green:.082 blue:.12 alpha:1]; card.layer.cornerRadius=24; card.layer.borderWidth=1; card.layer.borderColor=[UIColor colorWithWhite:1 alpha:.1].CGColor; card.translatesAutoresizingMaskIntoConstraints=NO;
 
 UILabel *eyebrow=[[UILabel alloc] initWithFrame:CGRectZero]; eyebrow.text=@"FILZA ACCESS CONTROL"; eyebrow.font=[UIFont systemFontOfSize:11 weight:UIFontWeightSemibold]; eyebrow.textColor=[UIColor colorWithRed:.62 green:.52 blue:1 alpha:1]; eyebrow.translatesAutoresizingMaskIntoConstraints=NO;
 
 UILabel *title=[[UILabel alloc] initWithFrame:CGRectZero]; title.text=@"Ativar dispositivo"; title.font=[UIFont systemFontOfSize:28 weight:UIFontWeightBold]; title.textColor=UIColor.whiteColor; title.translatesAutoresizingMaskIntoConstraints=NO;
 
 self.messageLabel=[[UILabel alloc] initWithFrame:CGRectZero]; self.messageLabel.numberOfLines=0; self.messageLabel.font=[UIFont systemFontOfSize:14]; self.messageLabel.textColor=[UIColor colorWithWhite:.7 alpha:1]; self.messageLabel.text=@"Insira sua key para vincular este dispositivo com segurança."; self.messageLabel.translatesAutoresizingMaskIntoConstraints=NO;
 
 self.codeField=[[UITextField alloc] initWithFrame:CGRectZero]; self.codeField.placeholder=@"Insira sua key"; self.codeField.font=[UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightMedium]; self.codeField.textColor=UIColor.whiteColor; self.codeField.autocapitalizationType=UITextAutocapitalizationTypeNone; self.codeField.autocorrectionType=UITextAutocorrectionTypeNo; self.codeField.keyboardType=UIKeyboardTypeASCIICapable; self.codeField.backgroundColor=[UIColor colorWithWhite:0 alpha:.28]; self.codeField.layer.cornerRadius=14; self.codeField.layer.borderWidth=1; self.codeField.layer.borderColor=[UIColor colorWithWhite:1 alpha:.1].CGColor; self.codeField.leftView=[[UIView alloc] initWithFrame:CGRectMake(0,0,16,1)]; self.codeField.leftViewMode=UITextFieldViewModeAlways; self.codeField.translatesAutoresizingMaskIntoConstraints=NO;
 
 self.continueButton=[UIButton buttonWithType:UIButtonTypeSystem]; [self.continueButton setTitle:@"Ativar dispositivo" forState:UIControlStateNormal]; self.continueButton.titleLabel.font=[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold]; self.continueButton.backgroundColor=[UIColor colorWithRed:.4 green:.28 blue:.95 alpha:1]; [self.continueButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal]; self.continueButton.layer.cornerRadius=14; self.continueButton.translatesAutoresizingMaskIntoConstraints=NO; [self.continueButton addTarget:self action:@sele











ctor:activate:) forControlEvents:UIControlEventTouchUpInside];
 self.activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium]; self.activityIndicator.color=UIColor.whiteColor; self.activityIndicator.hidesWhenStopped=YES; self.activityIndicator.translatesAutoresizingMaskIntoConstraints=NO;
 [self.view addSubview:card]; [card addSubview:eyebrow]; [card addSubview:title]; [card addSubview:self.messageLabel]; [card addSubview:self.codeField]; [card addSubview:self.continueButton]; [card addSubview:self.activityIndicator];
 [NSLayoutConstraint activateConstraints:@[[card.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],[card.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],[card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],[eyebrow.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24],[eyebrow.topAnchor constraintEqualToAnchor:card.topAnchor constant:26],[title.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24],[title.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24],[title.topAnchor constraintEqualToAnchor:eyebrow.bottomAnchor constant:8],[self.messageLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24],[self.messageLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24],[self.messageLabel.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:10],[self.codeField.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24],[self.codeField.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24],[self.codeField.topAnchor constraintEqualToAnchor:self.messageLabel.bottomAnchor constant:24],[self.codeField.heightAnchor constraintEqualToConstant:54],[self.continueButton.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:24],[self.continueButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-24],[self.continueButton.topAnchor constraintEqualToAnchor:self.codeField.bottomAnchor constant:14],[self.continueButton.heightAnchor constraintEqualToConstant:52],[self.continueButton.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-24],[self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.continueButton.centerXAnchor],[self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.continueButton.centerYAnchor]]]; [self ensureDeviceKey]; [self validateStoredToken];
}
- (void)ensureDeviceKey { NSData *tag=[KeychainTag dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary *q=@{(__bridge id)kSecClass:(__bridge id)kSecClassKey,(__bridge id)kSecAttrApplicationTag:tag,(__bridge id)kSecReturnRef:@YES}; SecKeyRef existing=NULL; if(SecItemCopyMatching((__bridge CFDictionaryRef)q,(CFTypeRef *)&existing)==errSecSuccess){self.privateKey=existing;return;} NSDictionary *a=@{(__bridge id)kSecAttrKeyType:(__bridge id)kSecAttrKeyTypeECSECPrimeRandom,(__bridge id)kSecAttrKeySizeInBits:@256,(__bridge id)kSecPrivateKeyAttrs:@{(__bridge id)kSecAttrIsPermanent:@YES,(__bridge id)kSecAttrApplicationTag:tag}}; self.privateKey=SecKeyCreateRandomKey((__bridge CFDictionaryRef)a,NULL); }
- (NSString *)publicKeyPEM { SecKeyRef pub=SecKeyCopyPublicKey(self.privateKey); CFDataRef d=SecKeyCopyExternalRepresentation(pub,NULL); if(pub)CFRelease(pub); if(!d)return nil; NSString *b=[(__bridge NSData *)d base64EncodedStringWithOptions:0]; CFRelease(d); return [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----",b]; }
- (void)postJSON:(NSDictionary *)body path:(NSString *)path completion:(void (^)(NSDictionary *,NSError *))completion { NSURL *u=[NSURL URLWithString:[API_BASE_URL stringByAppendingString:path]]; NSMutableURLRequest *r=[NSMutableURLRequest requestWithURL:u]; r.HTTPMethod=@"POST"; [r setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; r.HTTPBody=[NSJSONSerialization dataWithJSONObject:body options:0 error:nil]; [[[NSURLSession sharedSession] dataTaskWithRequest:r completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){ NSDictionary *j=data?[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]:nil; dispatch_async(dispatch_get_main_queue(),^{ completion(j,error); }); }] resume]; }
- (void)validateStoredToken { NSDictionary *q=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:KeychainToken,(__bridge id)kSecReturnData:@YES}; CFTypeRef ref=NULL; if(SecItemCopyMatching((__bridge CFDictionaryRef)q,&ref)!=errSecSuccess)return; NSData *d=CFBridgingRelease(ref); NSString *code=[[NSString alloc]initWithData:d encoding:NSUTF8StringEncoding]; if(!code.length)return; [self postJSON:@{@"key":code,@"installationId":[self publicKeyPEM]?:@""} path:@"/api/license/validate" completion:^(NSDictionary *j,NSError *e){ if(!e && [j[@"status"] isEqual:@"active"]) [self dismissViewControllerAnimated:NO completion:nil]; else { SecItemDelete((__bridge CFDictionaryRef)q); self.messageLabel.text=@"Esta ativação não está mais válida. Informe uma nova key."; } }]; }
- (void)activate:(id)sender { NSString *code=[self.codeField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]; NSString *pub=[self publicKeyPEM]; if(!code.length||!pub.length){self.messageLabel.text=@"Informe uma key válida.";return;} self.continueButton.enabled=NO; [self.activityIndicator startAnimating]; [self postJSON:@{@"key":code,@"installationId":pub} path:@"/api/license/activate" completion:^(NSDictionary *j,NSError *e){ self.continueButton.enabled=YES; [self.activityIndicator stopAnimating]; NSString *s=[j[@"status"] isKindOfClass:NSString.class]?j[@"status"]:@"invalid"; if(e||![s isEqualToString:@"active"]){NSDictionary *m=@{@"invalid":@"Key inválida ou inexistente.",@"expired":@"Esta key expirou.",@"disabled":@"Esta key está bloqueada.",@"revoked":@"Esta key foi revogada.",@"device_mismatch":@"Esta key já está vinculada a outro dispositivo.",@"rate_limited":@"Muitas tentativas. Tente novamente mais tarde."}; self.messageLabel.text=m[s]?:@"Não foi possível ativar a licença.";return;} NSData *d=[code dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary *item=@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:KeychainToken,(__bridge id)kSecValueData:d,(__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly}; SecItemDelete((__bridge CFDictionaryRef)@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecAttrAccount:KeychainToken}); SecItemAdd((__bridge CFDictionaryRef)item,NULL); [self dismissViewControllerAnimated:YES completion:nil]; }]; }
@end
