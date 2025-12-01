//
//  LoginViewController.m
//  ObjcApp
//

#import "LoginViewController.h"
#import "SWRevealViewController.h"
#import "ProductListViewController.h"

@interface LoginViewController ()

@property (nonatomic, strong) NSArray *validCredentials;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize credentials array
    self.validCredentials = @[@{
        @"email": @"omni20250101",
        @"password": @"omni1234"
    }];
    
    [self setupUI];
    [self setupGestures];
    // OmniSegment SDK
    // Manually set current page for analytics tracking
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-current-page
    [OmniSegment setCurrentPage:@"Login"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if already logged in
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
        [self performSegueWithIdentifier:@"showProductList" sender:self];
    }
}

- (void)setupUI {
    self.title = @"Login";
    
    // Configure text fields
    self.txtEmail.delegate = self;
    self.txtPassword.delegate = self;
    
    // Set default credentials for testing
    self.txtEmail.text = @"omni20250101";
    self.txtPassword.text = @"omni1234";
    
    // Configure button
    [self.btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnLogin.layer.cornerRadius = 5.0;
    self.btnLogin.clipsToBounds = YES;

    // Configure register button
[self.btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
self.btnRegister.layer.cornerRadius = 5.0;
self.btnRegister.clipsToBounds = YES;
}

- (void)setupGestures {
    // Add tap gesture to dismiss keyboard
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Actions

- (IBAction)loginButtonPressed:(id)sender {
    [self dismissKeyboard];
    
    // Validate inputs
    if (![self validateInputs]) {
        [self showAlertWithTitle:@"Error" message:@"Please enter both email and password"];
        return;
    }
    
    // Check credentials
    if ([self checkCredentials]) {
        [self handleSuccessfulLogin];
    } else {
        [self showAlertWithTitle:@"Login Failed" message:@"Invalid username or password"];
    }
}

- (IBAction)registerButtonPressed:(id)sender {
    // Track completeRegistration event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    NSDictionary *label = @{
        @"email": @"renee.wei@bebit-tech.com",
        @"regType": @"google"
    };
    OSGEvent *event = [OSGEvent completeRegistrationWithLabel:label];
    event.location = @"login_page";
    event.locationTitle = @"login_page";
    [OmniSegment trackEvent:event];
    [self showAlertWithTitle:@"註冊" message:@"註冊功能即將推出"];
}

#pragma mark - Helper Methods

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)validateInputs {
    return self.txtEmail.text.length > 0 && self.txtPassword.text.length > 0;
}

- (BOOL)checkCredentials {
    NSString *email = self.txtEmail.text;
    NSString *password = self.txtPassword.text;
    
    // Check if credentials match any valid pair
    for (NSDictionary *credentials in self.validCredentials) {
        if ([credentials[@"email"] isEqualToString:email] &&
            [credentials[@"password"] isEqualToString:password]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)handleSuccessfulLogin {
    // Save login state
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // After the user logs in, sdk can use it when sending records
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#login
    [OmniSegment loginWithUid:@"omnisegment20240101"];

    // If the user has logged-in and you need to set the uid without login event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-user-uid
    [OmniSegment setUidWithUid:@"omnisegment20240101"];


    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setupMainInterface];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    [appDelegate.window.layer addAnimation:transition forKey:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtEmail) {
        [self.txtPassword becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self loginButtonPressed:nil];
    }
    return YES;
}

@end
