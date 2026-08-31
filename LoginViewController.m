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
  self.eyebrowLabel.text = @"FILZA ACCESS CONTROL";
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
  self.messageLabel.text = @"Insira sua key para vincular este dispositivo com segurança.";
  self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;


  self.codeField = [[UITextField alloc] initWithFrame:CGRectZero];
  self.codeField.placeholder = @"Insira sua key";
  self.codeField.font = [UIFont monospacedSystemFontOfSize:16 weight:UIFontWeightMedium];
  self.codeField.textColor = UIColor.whiteColor;
  self.codeField.tintColor = [UIColor colorWithRed:0.62 green:0.52 blue:1 alpha:1];
  self.codeField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  self.codeField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.codeField.keyboardType = UIKeyboardTypeASCIICapable;
  self.codeField.backgroundColor = [UIColor colorWithWhite:0 alpha:0.28];
  self.codeField.layer.cornerRadius = 14;
