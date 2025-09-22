//
//  ProductListViewController.h
//  ObjcApp
//
//  Created by 魏偌帆 on 2024/10/29.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"


@interface ProductListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSMutableArray *cartItems;
@property (strong, nonatomic) NSMutableArray *wishlistItems;
@end
