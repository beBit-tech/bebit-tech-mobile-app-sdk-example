#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <OmniSegmentKit/OmniSegmentKit-Swift.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"xxxxx_xxxxx_App";
  // OmniSegmentKit SDK Initialization
  // Installation Guide: https://github.com/beBit-tech/bebit-tech-react-native-app-sdk/wiki/Installation
  // Enable debug logs and initialize with API key and TID
   // Please modify the key and tid from your omnisegment organization setting

  [OmniSegment initialize: @"XXXXXX-XXXXX-XXXXX-XXXXX-XXXXXX" withTid: @"OA-XXXXXX"];
  [OmniSegment enableDebugLogs:YES];

  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
