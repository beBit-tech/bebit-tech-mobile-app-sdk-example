//
//  CartViewController.h
//  ObjcApp
//
//  Created by 魏偌帆 on 2024/10/30.
#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import <OmniSegmentKit/OmniSegmentKit-Swift.h> // BeBit Tech analytics SDK for e-commerce event tracking

@interface CartViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *checkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *refundButton;
@property (strong, nonatomic) NSMutableArray *cartItems;

@end
