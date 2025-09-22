//
//  SidebarTableViewController.m
//  ObjcApp

#import "SidebarTableViewController.h"
#import "CartViewController.h"
#import "ProductListViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"



@interface SidebarTableViewController () <UISearchBarDelegate>
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) NSArray *filteredMenuItems;
@property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation SidebarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // menuItems
    self.menuItems = @[
        @{@"title" : @"商品列表", @"identifier" : @"ProductNavigationController"},
        @{@"title" : @"購物車", @"identifier" : @"CartViewController"},
        @{@"title" : @"WEBVIEW", @"identifier" : @"WebViewController"},
        @{@"title" : @"登出", @"identifier" : @"Logout"}
    ];
    
    self.filteredMenuItems = [self.menuItems copy];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 56)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"搜尋";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.barTintColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    self.searchBar.tintColor = [UIColor whiteColor];
    
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTextColor:[UIColor whiteColor]];
    
    self.tableView.tableHeaderView = self.searchBar;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor darkGrayColor];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MenuCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
    
    NSDictionary *item = self.filteredMenuItems[indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = self.filteredMenuItems[indexPath.row];
    NSString *identifier = item[@"identifier"];
    
    if ([identifier isEqualToString:@"Logout"]) {
        [self handleLogout];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *destinationVC;
    
    if ([identifier isEqualToString:@"ProductNavigationController"]) {
        destinationVC = [storyboard instantiateViewControllerWithIdentifier:@"ProductNavigationController"];
    } else if ([identifier isEqualToString:@"CartViewController"]) {
        CartViewController *cartVC = [storyboard instantiateViewControllerWithIdentifier:@"CartViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cartVC];
        navController.navigationBar.barTintColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
        navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        destinationVC = navController;
    } else if ([identifier isEqualToString:@"WebViewController"]) {
        WebViewController *webVC = [storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webVC];
        navController.navigationBar.barTintColor = [UIColor colorWithRed:0.122 green:0.129 blue:0.141 alpha:1.0];
        navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        destinationVC = navController;
    }
    
    if (destinationVC) {
        [self.revealViewController setFrontViewController:destinationVC animated:YES];
        [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.filteredMenuItems = [self.menuItems copy];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *item, NSDictionary *bindings) {
            return [item[@"title"] localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredMenuItems = [self.menuItems filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    // Track Search Event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    NSDictionary *searchLabel = @{@"search_string": searchBar.text};
    OSGEvent *event = [OSGEvent searchWithLabel:searchLabel];
    event.location = @"app://sidebar";
    event.locationTitle = @"sidebar";
    [OmniSegment trackEvent:event];
}

#pragma mark - Logout Handler

- (void)handleLogout {
    // Track appUnsubscribe event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGEvent *event = [OSGEvent appUnsubscribe];
    event.location = @"sidebar";
    event.locationTitle = @"Sidebar";
    [OmniSegment trackEvent:event];

    // Track When the user logs out
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#logout
    [OmniSegment logout];

    // If you want to reset uid without logout event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#clear-user-uid
    [OmniSegment clearUid];
    
    // Clear login state
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setupLoginInterface];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    [appDelegate.window.layer addAnimation:transition forKey:nil];
}

@end
