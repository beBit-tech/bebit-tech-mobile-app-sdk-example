//
//  MainViewController.m
//  ObjcApp
//

#import "MainViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@interface MainViewController ()
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupSidebarMenu];
    [self setupGestureRecognizers];
}

- (void)setupUI {
    self.title = @"Product";
    
    // Initialize content dictionary
    self.contentDict = [NSMutableDictionary dictionary];
    
    // Setup delegates
    self.txtPrice.delegate = self;
    self.txtProductName.delegate = self;
    self.txtViewDescription.delegate = self;
    
    // Set initial values
    self.txtPrice.text = self.productPrice;
    self.txtProductName.text = self.productName;
    self.txtViewDescription.text = self.productDescription;
    
    // Set keyboard appearance
    self.txtPrice.keyboardAppearance = UIKeyboardAppearanceDark;
    self.txtProductName.keyboardAppearance = UIKeyboardAppearanceDark;
    self.txtViewDescription.keyboardAppearance = UIKeyboardAppearanceDark;
}

- (void)setupSidebarMenu {
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

- (void)setupGestureRecognizers {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self
                                  action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    [self loadExistingProductData];
    
    OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:[NSString stringWithFormat:@"%@", 
                                                            [self.contentDict valueForKey:@"ID"]] 
                                                      name:[self.contentDict valueForKey:@"ProductName"]];
    osgProduct.price = @([[self.contentDict valueForKey:@"ProductPrice"] intValue]);
    osgProduct.brand = @"chiikawa";
    osgProduct.sku = @"chiikawawa";
    osgProduct.variant = @"{\"color\": \"white\"}";
    
    // Track impression event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGEvent *event = [OSGEvent productImpression:@[osgProduct]];
    event.location = @"app://product-detail";
    event.locationTitle = @"product-detail";
    event.currencyCode = @"TWD";
    [OmniSegment trackEvent:event];

    // Manually set current page for analytics tracking
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-current-page
    [OmniSegment setCurrentPage:@"Home"];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)loadExistingProductData {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.checkNewAcc) {
        NSArray *savedProducts = [[NSUserDefaults standardUserDefaults] arrayForKey:@"saved_products"];
        if (savedProducts && self.indexValue < savedProducts.count) {
            self.contentDict = [[savedProducts objectAtIndex:self.indexValue] mutableCopy];
            self.txtProductName.text = [self.contentDict valueForKey:@"ProductName"];
            self.txtViewDescription.text = [self.contentDict valueForKey:@"ProductDescription"];
            self.txtPrice.text = [self.contentDict valueForKey:@"ProductPrice"];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = -keyboardSize.height + 140;
        self.view.frame = frame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0.0f;
        self.view.frame = frame;
    }];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Button Actions

- (IBAction)btnDonePressed:(id)sender {
    if (![self validateInputs]) {
        [self showAlertWithTitle:@"Error" message:@"Please fill in all required fields"];
        return;
    }

    NSDictionary *productToAdd = @{
        @"ProductName": self.txtProductName.text,
        @"ProductDescription": self.txtViewDescription.text,
        @"ProductPrice": self.txtPrice.text,
        @"ID": @(arc4random_uniform(1000))
    };
    
    // 從 UserDefaults 取得現有購物車項目
    NSMutableArray *cartItems = [NSMutableArray array];
    NSArray *savedCartItems = [[NSUserDefaults standardUserDefaults] arrayForKey:@"cart_items"];
    if (savedCartItems) {
        cartItems = [savedCartItems mutableCopy];
    }
    
    [cartItems addObject:productToAdd];
    
    [[NSUserDefaults standardUserDefaults] setObject:cartItems forKey:@"cart_items"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Track add to cart event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:[NSString stringWithFormat:@"%@", productToAdd[@"ID"]] 
                                                      name:productToAdd[@"ProductName"]];
    osgProduct.price = @([productToAdd[@"ProductPrice"] intValue]);
    osgProduct.brand = @"chiikawa";
    osgProduct.sku = @"chiikawawa";
    osgProduct.variant = @"{\"color\": \"white\"}";
    
    OSGEvent *event = [OSGEvent addToCart:@[osgProduct]];
    event.location = @"ProductDetail";
    event.locationTitle = @"ObjcApp";
    event.currencyCode = @"TWD";
    
    [OmniSegment trackEvent:event];

    [self showAlertWithTitle:@"Success" message:@"Product added to cart successfully!"];
}

- (BOOL)validateInputs {
    return ![self.txtProductName.text isEqualToString:@""] &&
           ![self.txtPrice.text isEqualToString:@""];
}

- (void)saveProduct {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *products = [self getSavedProducts];
    
    if (appDelegate.checkNewAcc) {
        [self handleNewProduct:products];
    } else {
        [self handleExistingProduct:products];
    }
}

- (NSMutableArray *)getSavedProducts {
    NSArray *savedProducts = [[NSUserDefaults standardUserDefaults] arrayForKey:@"saved_products"];
    return savedProducts ? [savedProducts mutableCopy] : [NSMutableArray array];
}

- (void)handleNewProduct:(NSMutableArray *)products {
    NSInteger newId = [self getNextAvailableId:products];
    [self updateContentDict:newId];
    [products addObject:self.contentDict];
    [self saveProductsToUserDefaults:products];
    [self showAlertWithTitle:@"Success" message:@"Product added successfully!"];
}

- (void)handleExistingProduct:(NSMutableArray *)products {
    if (self.indexValue < products.count) {
        NSNumber *existingId = [[products objectAtIndex:self.indexValue] valueForKey:@"ID"];
        [self updateContentDict:[existingId intValue]];
        [products replaceObjectAtIndex:self.indexValue withObject:self.contentDict];
        [self saveProductsToUserDefaults:products];
    }
}

- (NSInteger)getNextAvailableId:(NSArray *)products {
    NSInteger nextId = 101;
    NSMutableSet *usedIds = [NSMutableSet set];
    
    for (NSDictionary *product in products) {
        [usedIds addObject:[product valueForKey:@"ID"]];
    }
    
    while ([usedIds containsObject:@(nextId)]) {
        nextId++;
    }
    
    return nextId;
}

- (void)updateContentDict:(NSInteger)productId {
    [self.contentDict setObject:@(productId) forKey:@"ID"];
    [self.contentDict setObject:self.productName ?: @"" forKey:@"ProductName"];
    [self.contentDict setObject:self.productPrice ?: @"" forKey:@"ProductPrice"];
    [self.contentDict setObject:self.productDescription ?: @"" forKey:@"ProductDescription"];
}

- (void)saveProductsToUserDefaults:(NSArray *)products {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveDictionaryToUserDefaults:products :@"saved_products"];
}

#pragma mark - Tax Calculations

- (IBAction)btnMITaxPressed:(id)sender {
    [self calculateTaxWithRate:0.07];
    
    // Trackadd to wishlist event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGProduct *osgProduct = [[OSGProduct alloc] initWithId:@"MI-TAX-001" 
                                                      name:@"Michigan Tax Calculator"];
    osgProduct.brand = @"chiikawa";
    osgProduct.sku = @"chiikawawa";
    osgProduct.variant = @"{\"type\": \"chiikawawa\"}";
    
    OSGEvent *event = [OSGEvent addToWishlist:@[osgProduct]];
    event.location = @"app://product-detail";
    event.locationTitle = @"product-detail";
    event.currencyCode = @"TWD";
    [OmniSegment trackEvent:event];
}

- (IBAction)btnINTaxPressed:(id)sender {
    [self calculateTaxWithRate:0.06];
}

- (void)calculateTaxWithRate:(float)rate {
    if ([self.txtPrice.text isEqualToString:@""] || !self.txtPrice.text) {
        [self showAlertWithTitle:@"Empty Field" message:@"Please insert a Price first!"];
        return;
    }
    
    float currentValue = [self.txtPrice.text floatValue];
    currentValue = (currentValue * rate) + currentValue;
    self.txtPrice.text = [NSString stringWithFormat:@"%.2f", currentValue];
    self.productPrice = self.txtPrice.text;
}




#pragma mark - Helper Methods

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextField/UITextView Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.txtPrice resignFirstResponder];
    [self.txtProductName resignFirstResponder];
    [self.txtViewDescription resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.txtProductName) {
        self.productName = self.txtProductName.text;
    } else if (textField == self.txtPrice) {
        self.productPrice = self.txtPrice.text;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == self.txtViewDescription) {
        self.productDescription = self.txtViewDescription.text;
    }
}

@end
