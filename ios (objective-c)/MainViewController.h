//
//  MainViewController.h
//  ObjcApp


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import <OmniSegmentKit/OmniSegmentKit-Swift.h> // BeBit Tech analytics SDK for manual page tracking

@interface MainViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITextField *txtProductName;
@property (weak, nonatomic) IBOutlet UITextView *txtViewDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIButton *btnINTax;
@property (weak, nonatomic) IBOutlet UIButton *btnMITax;

@property NSString *productName;
@property NSString *productDescription;
@property NSString* productPrice;

@property NSMutableArray* accounts;
@property (strong, nonatomic) NSMutableDictionary *contentDict;
@property NSMutableDictionary *productDict;
@property NSInteger indexValue;
@property bool newAccount;
@end
