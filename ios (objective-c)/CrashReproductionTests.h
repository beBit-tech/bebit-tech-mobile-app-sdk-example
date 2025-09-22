//
//  CrashReproductionTests.h
//  ObjcApp
//
//  Crash reproduction tests for OmniSegmentKit
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashReproductionTests : NSObject

+ (instancetype)sharedInstance;

// Memory pressure tests
- (void)testMemoryPressureDB;
- (void)testMemoryPressureWebViews;

// Database stress tests
- (void)testConcurrentDatabaseOperations;

// WebKit lifecycle tests
- (void)testWebKitLifecycleCrashes;

// JavaScript execution tests
- (void)testJavaScriptExecutionInterruption;

// Background/foreground tests
- (void)testBackgroundForegroundSwitching;

// Combined test
- (void)runAllCrashTests;

// Cleanup
- (void)stopAllTests;

@end

// UIViewController category for easy access
@interface UIViewController (CrashTesting)
- (void)startCrashTests;
@end

NS_ASSUME_NONNULL_END