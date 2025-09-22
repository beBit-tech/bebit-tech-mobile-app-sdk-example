//
//  WebViewController.h
//  ObjcApp
//
//  Created by 魏偌帆 on 2024/10/31.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "SWRevealViewController.h"
#import <OmniSegmentKit/OmniSegmentKit-Swift.h> // BeBit Tech analytics SDK for manual page tracking

@interface WebViewController : UIViewController <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) WKWebView *webView;

@end
