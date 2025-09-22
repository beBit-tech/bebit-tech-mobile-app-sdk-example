//
//  AppDelegate.m
//  ObjcApp

#import "AppDelegate.h"
#import "ProductListViewController.h"
#import "SWRevealViewController.h"
#import <OmniSegmentKit/OmniSegmentKit-Swift.h> // BeBit Tech user behavior analytics SDK - Main SDK for tracking user actions and events

@interface AppDelegate ()
@end

@implementation AppDelegate
@synthesize checkNewAcc;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    OmniSegment *omniSegmentInstance = [[OmniSegment alloc] init];

    // OmniSegmentKit SDK Initialization
    // Installation Guide: https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Installation
    // Enable debug logs and initialize with API key and TID
    // Please modify the key and tid from your omnisegment organization setting
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki#1-debug-logs-and-sdk-initialization
    [OmniSegment enableDebugLogs:YES];
    [OmniSegment initialize:@"xxxxx-xxx-xxx-xxx-xxxx" withTid:@"OA-XXX"];

    // Set application metadata for analytics identification
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events
    [OmniSegment setAppName:@"test-app"];
    [OmniSegment setBundleId:@"test-BundleId"];
    [OmniSegment setBundleVersion:@"test-20241030"];
    [OmniSegment setDeviceId:@"B3D94381-CF9A-4885-AEDD-D0B90F4AEF75"];

    // MARK: - Firebase FCM Token & Event Tracking
    // Handle FCM token registration and track app open events
    // FCM Token Setup: https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-firebase-cloud-messaging-token
    [OmniSegment setFCMToken:@"fake-fcm-token-for-testing"];
    
    // If the user has logged-in and you need to set the uid without login event
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#objective-c-2
    [OmniSegment setUidWithUid:@"omnisegment20240101"];

    // Track app open
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Track-events#build-in-events
    OSGEvent *event = [OSGEvent appOpen];
    event.location = @"home_page";
    event.locationTitle = @"home_page";
    [OmniSegment trackEvent:event];




    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"];
    
    if (isLoggedIn) {
        [self setupMainInterface];
    } else {
        [self setupLoginInterface];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupLoginInterface {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.window.rootViewController = loginViewController;
}

- (void)setupMainInterface {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Setup main navigation
    ProductListViewController *productListVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ProductListViewController"];
    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:productListVC];
    
    // Setup sidebar menu
    UIViewController *rearViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"SidebarTableViewController"];
    
    // Setup reveal controller
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:frontNavigationController];
    revealController.rearViewRevealWidth = 260;
    revealController.toggleAnimationDuration = 0.3;
    
    self.window.rootViewController = revealController;
}

#pragma mark - Data Management

- (void)saveStringToUserDefaults:(NSString*)myString :(NSString*)myKey {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myString forKey:myKey];
        [standardUserDefaults synchronize];
    }
}

- (void)saveDictionaryToUserDefaults:(NSMutableArray*)myArray :(NSString*)myKey {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:myArray forKey:myKey];
        [standardUserDefaults synchronize];
    }
}

#pragma mark - Shared Instance

+ (AppDelegate *)sharedAppDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - Application Lifecycle

- (void)applicationWillResignActive:(UIApplication *)application {
    // Save any pending changes
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Save any pending changes
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Refresh data if needed
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Refresh interface if needed
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Save any pending changes
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
