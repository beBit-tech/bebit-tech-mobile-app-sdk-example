//
//  ProductListViewController.m
//  ObjcApp
//
//  Created by 魏偌帆 on 2024/10/29.
//


#import "ProductListViewController.h"
#import "AppDelegate.h"
#import "ProductListViewController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "SWRevealViewController.h"
#import "CartViewController.h"

@interface ProductListViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation ProductListViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"RevealViewController: %@", self.revealViewController);
    NSLog(@"SidebarButton: %@", self.sidebarButton);
    
    [self setupNavigationBar];
    [self setupTableView];
    [self setupSidebarMenu];
    [self initializeData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
    
    NSMutableArray *osgProducts = [NSMutableArray array];

    // Track impression event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    for (NSDictionary *product in self.products) {
        OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:[NSString stringWithFormat:@"%@", product[@"ID"]] 
                                                          name:product[@"ProductName"]];
        osgProduct.price = @([product[@"ProductPrice"] intValue]);
        osgProduct.category = product[@"Category"];
        osgProduct.brand = @"chiikawa";
        osgProduct.sku = @"chiikawawa";
        osgProduct.variant = @"{\"color\": \"white\"}";
        [osgProducts addObject:osgProduct];
    }
    
    OSGEvent *event = [OSGEvent productImpression:osgProducts];
    event.location = @"app://product-list";
    event.locationTitle = @"product-list-page";
    event.currencyCode = @"TWD";
    [OmniSegment trackEvent:event];
    // OmniSegment SDK
    // Manually set current page for analytics tracking
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-current-page
    [OmniSegment setCurrentPage:@"Home"];
}

#pragma mark - Setup Methods

- (void)setupNavigationBar {
    // Configure navigation bar
    self.title = @"商品列表";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // Add cart button
    UIBarButtonItem *cartButton = [[UIBarButtonItem alloc]
                                  initWithImage:[UIImage systemImageNamed:@"cart"]
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(cartButtonTapped)];
    cartButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = cartButton;
}

- (void)setupTableView {
    // Configure table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor darkGrayColor];
    
    // Add refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)setupSidebarMenu {
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        
        self.sidebarButton.tintColor = [UIColor whiteColor];
        
        if (!self.sidebarButton) {
            NSLog(@"Warning: Sidebar button outlet not connected!");
        }
    } else {
        NSLog(@"Warning: RevealViewController not found!");
    }
}

#pragma mark - Data Management

- (void)initializeData {
    // Initialize arrays
    self.products = [NSMutableArray array];
    self.cartItems = [NSMutableArray array];
    self.wishlistItems = [NSMutableArray array];
    
    // Load saved data
    [self loadSavedProducts];
    [self loadCartItems];
    [self loadWishlistItems];
}

- (void)loadSavedProducts {
    NSArray *savedProducts = [[NSUserDefaults standardUserDefaults] arrayForKey:@"saved_products"];
    if (savedProducts.count > 0) {
        [self.products addObjectsFromArray:savedProducts];
    } else {
        [self createSampleProducts];
    }
}

- (void)createSampleProducts {
    NSArray *sampleProducts = @[
        @{
            @"ID": @101,
            @"ProductName": @"精品咖啡",
            @"ProductDescription": @"來自哥倫比亞的優質阿拉比卡咖啡豆",
            @"ProductPrice": @"399",
            @"Category": @"飲品"
        },
        @{
            @"ID": @102,
            @"ProductName": @"有機綠茶",
            @"ProductDescription": @"日本靜岡縣產特級綠茶葉",
            @"ProductPrice": @"299",
            @"Category": @"飲品"
        },
        @{
            @"ID": @103,
            @"ProductName": @"手工餅乾",
            @"ProductDescription": @"使用天然食材製作的美味餅乾",
            @"ProductPrice": @"199",
            @"Category": @"食品"
        },
        @{
            @"ID": @104,
            @"ProductName": @"有機蜂蜜",
            @"ProductDescription": @"純天然龍眼花蜜",
            @"ProductPrice": @"499",
            @"Category": @"食品"
        },
        @{
            @"ID": @105,
            @"ProductName": @"巧克力蛋糕",
            @"ProductDescription": @"比利時巧克力製作的濃郁蛋糕",
            @"ProductPrice": @"599",
            @"Category": @"甜點"
        }
    ];
    
    [self.products addObjectsFromArray:sampleProducts];
    [self saveProducts];
}

- (void)loadCartItems {
    NSArray *savedCartItems = [[NSUserDefaults standardUserDefaults] arrayForKey:@"cart_items"];
    if (savedCartItems) {
        self.cartItems = [savedCartItems mutableCopy];
    }
}

- (void)loadWishlistItems {
    NSArray *savedWishlistItems = [[NSUserDefaults standardUserDefaults] arrayForKey:@"wishlist_items"];
    if (savedWishlistItems) {
        self.wishlistItems = [savedWishlistItems mutableCopy];
    }
}

- (void)saveProducts {
    [[NSUserDefaults standardUserDefaults] setObject:self.products forKey:@"saved_products"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveCartItems {
    [[NSUserDefaults standardUserDefaults] setObject:self.cartItems forKey:@"cart_items"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveWishlistItems {
    [[NSUserDefaults standardUserDefaults] setObject:self.wishlistItems forKey:@"wishlist_items"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UI Actions

- (void)refreshData {
    // Simulate network delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadSavedProducts];
        [self loadCartItems];
        [self loadWishlistItems];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}

- (void)reloadData {
    [self loadSavedProducts];
    [self loadCartItems];
    [self loadWishlistItems];
    [self.tableView reloadData];
}

- (void)cartButtonTapped {

    // ISO 8601
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    // OmniSegment SDK custom event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Send-Action-(Event)-Examples#custom-event
    // Purpose: Track custom events specific to your business needs (e.g., newsletter subscription)
    NSDictionary *eventData = @{
        @"ClickDate": currentDate,
        @"EmailEvent": @"renee.wei@bebit-tech.com",
        @"CampaignName": @"bebit"
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:eventData 
                                                      options:0 
                                                        error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
  OSGEvent *event = [OSGEvent customWithAction:@"EmailEvent" value:jsonString];
    event.location = @"app://product-list";
    event.locationTitle = @"product-list-page";
    [OmniSegment trackEvent:event];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CartViewController *cartVC = [storyboard instantiateViewControllerWithIdentifier:@"CartViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cartVC];
    [self.navigationController pushViewController:cartVC animated:YES];
}

- (void)addToCart:(UIButton *)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath) {
        NSDictionary *product = self.products[indexPath.row];
        [self.cartItems addObject:product];
        [self saveCartItems];
        
        [self showAlert:@"已加入購物車" message:[NSString stringWithFormat:@"%@ 已加入購物車", product[@"ProductName"]]];
    }
}

- (void)addToWishlist:(UIButton *)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (indexPath) {
        NSDictionary *product = self.products[indexPath.row];
        [self.wishlistItems addObject:product];
        [self saveWishlistItems];
        
        [self showAlert:@"已加入願望清單" message:[NSString stringWithFormat:@"%@ 已加入願望清單", product[@"ProductName"]]];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ProductCell"];
        
        // Configure cell appearance
        cell.backgroundColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        
        // Add cart button
        UIButton *cartButton = [UIButton buttonWithType:UIButtonTypeSystem];
        cartButton.frame = CGRectMake(cell.contentView.frame.size.width - 90, 10, 30, 30);
        [cartButton setImage:[UIImage systemImageNamed:@"cart"] forState:UIControlStateNormal];
        cartButton.tintColor = [UIColor whiteColor];
        [cartButton addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cartButton];
        
        // Add wishlist button
        UIButton *wishlistButton = [UIButton buttonWithType:UIButtonTypeSystem];
        wishlistButton.frame = CGRectMake(cell.contentView.frame.size.width - 50, 10, 30, 30);
        [wishlistButton setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
        wishlistButton.tintColor = [UIColor whiteColor];
        [wishlistButton addTarget:self action:@selector(addToWishlist:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:wishlistButton];
    }
    
    // Configure cell data
    NSDictionary *product = self.products[indexPath.row];
    cell.textLabel.text = product[@"ProductName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"NT$ %@", product[@"ProductPrice"]];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // get product
    NSDictionary *selectedProduct = self.products[indexPath.row];
    
    // Track click product event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:[NSString stringWithFormat:@"%@", selectedProduct[@"ID"]] 
                                                      name:selectedProduct[@"ProductName"]];
    osgProduct.price = @([selectedProduct[@"ProductPrice"] intValue]);
    osgProduct.category = selectedProduct[@"Category"];
    osgProduct.brand = @"chiikawa";           
    osgProduct.sku = @"chiikawawa";           
    osgProduct.variant = @"{\"color\": \"white\"}";  
    
    // clickProduct
    OSGEvent *event = [OSGEvent productClicked:@[osgProduct]];
    event.location = @"ProductList";
    event.locationTitle = @"ObjcApp";
    event.currencyCode = @"TWD";
    [OmniSegment trackEvent:event];

    [self navigateToProductDetail:selectedProduct];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Navigation

- (void)navigateToProductDetail:(NSDictionary *)product {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainViewController *detailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    detailVC.productName = product[@"ProductName"];
    detailVC.productDescription = product[@"ProductDescription"];
    detailVC.productPrice = product[@"ProductPrice"];
    detailVC.indexValue = [self.products indexOfObject:product];
    detailVC.newAccount = NO;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Helper Methods

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"確定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
