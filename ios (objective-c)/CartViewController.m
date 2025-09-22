//
//  CartViewController.m
//  ObjcApp
//
//  Created by 魏偌帆 on 2024/10/30.
//

#import "CartViewController.h"

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"購物車";
    
    // Setup sidebar menu
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    // Initialize cart items array
    self.cartItems = [NSMutableArray array];
    
    // Setup table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Setup buttons
    [self setupButtons];
    
    // Load cart items
    [self loadCartItems];

    // Manually set current page for analytics tracking
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-current-page
    [OmniSegment setCurrentPage:@"Cart"];

}

- (void)setupButtons {
    // Checkout button setup
    self.checkoutButton.backgroundColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    [self.checkoutButton setTitle:@"結帳(checkout)" forState:UIControlStateNormal];
    [self.checkoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.checkoutButton.layer.cornerRadius = 5.0;
    [self.checkoutButton addTarget:self action:@selector(checkoutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Purchase button setup
    self.purchaseButton.backgroundColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    [self.purchaseButton setTitle:@"購買" forState:UIControlStateNormal];
    [self.purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.purchaseButton.layer.cornerRadius = 5.0;
    [self.purchaseButton addTarget:self action:@selector(purchaseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // Refund button setup
    self.refundButton.backgroundColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    [self.refundButton setTitle:@"退款" forState:UIControlStateNormal];
    [self.refundButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.refundButton.layer.cornerRadius = 5.0;
    [self.refundButton addTarget:self action:@selector(refundButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadCartItems {
    NSArray *savedCartItems = [[NSUserDefaults standardUserDefaults] arrayForKey:@"cart_items"];
    if (savedCartItems) {
        self.cartItems = [savedCartItems mutableCopy];
        NSLog(@"已加載購物車項目: %@", self.cartItems); // 添加调试输出
        [self.tableView reloadData];
    } else {
        NSLog(@"購物車為空");
    }
}

#pragma mark - Button Actions

- (void)checkoutButtonTapped:(UIButton *)sender {
    if (self.cartItems.count == 0) {
        [self showAlertWithTitle:@"購物車為空" message:@"請先添加商品到購物車"];
        return;
    }
    
    [self showAlertWithTitle:@"結帳確認" message:@"確定要結帳嗎？" 
                  okHandler:^(UIAlertAction *action) {
        // Implement checkout logic here
        [self processCheckout];
    }];
}

- (void)purchaseButtonTapped:(UIButton *)sender {
    if (self.cartItems.count == 0) {
        [self showAlertWithTitle:@"購物車為空" message:@"請先添加商品到購物車"];
        return;
    }
    
    [self showAlertWithTitle:@"購買確認" message:@"確定要購買所有商品嗎？" 
                  okHandler:^(UIAlertAction *action) {
        // Implement purchase logic here
        [self processPurchase];
    }];
}

- (void)refundButtonTapped:(UIButton *)sender {
    if (self.cartItems.count == 0) {
        [self showAlertWithTitle:@"購物車為空" message:@"沒有可退款的商品"];
        return;
    }
    
    [self showAlertWithTitle:@"退款確認" message:@"確定要申請退款嗎？" 
                  okHandler:^(UIAlertAction *action) {
        // Implement refund logic here
        [self processRefund];
    }];
}

#pragma mark - Process Methods

- (void)processCheckout {
    // get product info
    NSMutableArray *osgProducts = [NSMutableArray array];
    for (NSDictionary *product in self.cartItems) {
        OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:[NSString stringWithFormat:@"%@", product[@"ID"]] 
                                                          name:product[@"ProductName"]];
        osgProduct.price = @([@"100" intValue]);
        osgProduct.category = @"Category";
        osgProduct.brand = @"chiikawa";
        osgProduct.sku = @"chiikawawa";
        osgProduct.variant = @"{\"color\": \"white\"}";
        [osgProducts addObject:osgProduct];
    }
    
    // Track checkout initiation event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGEvent *event = [OSGEvent checkout:osgProducts];
    event.location = @"app://cart";
    event.locationTitle = @"cart-page";
    event.currencyCode = @"TWD";
    [OmniSegment trackEvent:event];
    
    [self.cartItems removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cart_items"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
    [self showAlertWithTitle:@"成功" message:@"結帳完成！"];
}

- (void)processPurchase {
    // get product info
    NSMutableArray *osgProducts = [NSMutableArray array];
    int totalRevenue = 0;
    
    for (NSDictionary *product in self.cartItems) {
        OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:[NSString stringWithFormat:@"%@", product[@"ID"]] 
                                                          name:product[@"ProductName"]];
        osgProduct.price = @([@"100" intValue]);
        osgProduct.category = @"Category";
        osgProduct.brand = @"chiikawa";
        osgProduct.sku = @"chiikawawa";
        osgProduct.variant = @"{\"color\": \"white\"}";
        [osgProducts addObject:osgProduct];
        
        totalRevenue += [product[@"ProductPrice"] intValue];
    }
    
    NSString *transactionId = [NSString stringWithFormat:@"ORDER%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    // Track purchase event with transaction details
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGEvent *event = [OSGEvent purchaseWithTransactionId:transactionId revenue:@(totalRevenue) products:osgProducts];
    event.location = @"app://cart";
    event.locationTitle = @"cart-page";
    event.currencyCode = @"TWD";
    [OmniSegment trackEvent:event];
    
    [self.cartItems removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cart_items"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
    [self showAlertWithTitle:@"成功" message:@"購買完成！"];
}

- (void)processRefund {
    NSMutableArray *osgProducts = [NSMutableArray array];
    int totalRevenue = 0;
    
    for (NSDictionary *product in self.cartItems) {
        OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:[NSString stringWithFormat:@"%@", product[@"ID"]] 
                                                          name:product[@"ProductName"]];
        osgProduct.price = @([product[@"ProductPrice"] intValue]);
        osgProduct.category = product[@"Category"];
        osgProduct.brand = @"chiikawa";
        osgProduct.sku = @"chiikawawa";
        osgProduct.variant = @"{\"color\": \"white\"}";
        [osgProducts addObject:osgProduct];
        
        totalRevenue += [product[@"ProductPrice"] intValue];
    }
    
    NSString *transactionId = [NSString stringWithFormat:@"REFUND%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    // Track refund event with transaction details
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGEvent *event = [OSGEvent refundWithTransactionId:transactionId revenue:@(totalRevenue) products:osgProducts];
    event.location = @"app://cart";
    event.locationTitle = @"cart-page";
    event.currencyCode = @"TWD";
    [OmniSegment trackEvent:event];
    

    [self.cartItems removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cart_items"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
    [self showAlertWithTitle:@"成功" message:@"退款申請已提交！"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cartItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CartCell"];
    }

    cell.backgroundColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];

    NSDictionary *item = self.cartItems[indexPath.row];
    cell.textLabel.text = item[@"ProductName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"NT$ %@", item[@"ProductPrice"]];

    return cell;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadCartItems];
}

// 在 #pragma mark - Table view data source

// delete product by scroll
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *product = self.cartItems[indexPath.row];
        
        // handle product info
        NSNumber *productIdNumber = product[@"ID"];
        NSString *productId = [productIdNumber stringValue];
        
        NSLog(@"Product ID: %@", productId);
        
        OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:productId 
                                                          name:product[@"ProductName"]];
        osgProduct.price = @([product[@"ProductPrice"] intValue]);
        osgProduct.category = product[@"Category"];
        osgProduct.brand = @"chiikawa";           
        osgProduct.sku = @"chiikawawa";           
        osgProduct.variant = @"{\"color\": \"white\"}";  
        
        // Remove from cart event with product details
        // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
        OSGEvent *event = [OSGEvent removeFromCart:@[osgProduct]];
        event.location = @"Cart";
        event.locationTitle = @"ObjcApp";
        event.currencyCode = @"TWD";
        [OmniSegment trackEvent:event];
        
        [self.cartItems removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:self.cartItems forKey:@"cart_items"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
#pragma mark - Helper Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertWithTitle:title message:message okHandler:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message okHandler:(void (^)(UIAlertAction *action))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"確定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:handler];
    
    [alert addAction:okAction];
    
    if (handler) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
        [alert addAction:cancelAction];
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
