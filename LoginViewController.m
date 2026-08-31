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
 
 self.continueButton=[UIButton buttonWithType:UIButtonTypeSystem]; [self.continueButton setTitle:@"Ativar dispositivo" forState:UIControlStateNormal]; self.continueButton.titleLabel.font=[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold]; self.continueButton.backgroundColor=[UIColor colorWithRed:.4 green:.28 blue:.95 alpha:1]; [self.continueButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal]; self.continueButton.layer.cornerRadius=14; self.continueButton.translatesAutoresizingMaskIntoConstraints=NO; [self.continueButton addTarget:self action:@selector(activate:) forControlEvents:UIControlEventTouchUpInside];


