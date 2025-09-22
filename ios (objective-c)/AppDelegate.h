//
//  AppDelegate.h
//  ObjcApp

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property bool checkNewAcc;

// Navigation methods
- (void)setupLoginInterface;
- (void)setupMainInterface;

// Data management methods
- (void)saveStringToUserDefaults:(NSString*)myString :(NSString*)myKey;
- (void)saveDictionaryToUserDefaults:(NSMutableArray*)myArray :(NSString*)myKey;

// Shared instance method
+ (AppDelegate *)sharedAppDelegate;

@end