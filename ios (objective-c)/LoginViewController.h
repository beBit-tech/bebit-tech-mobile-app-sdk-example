//
//  LoginViewController.h
//  ObjcApp
//
//  Created by 魏偌帆 on 2024/10/29.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <OmniSegmentKit/OmniSegmentKit-Swift.h> // BeBit Tech analytics SDK for e-commerce event tracking



@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;

@end
