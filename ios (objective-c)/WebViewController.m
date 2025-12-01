//
//  WebViewController.m
//  ObjcApp
//
//  Created by 魏偌帆 on 2024/10/31.
//
#import "WebViewController.h"

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WEBVIEW";
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget:revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    // Configure WebView
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    [configuration setApplicationNameForUserAgent:@"AppWebView"];
    
    if (@available(iOS 13.0, *)) {
        // ensure that events within webview pages are tracked by the SDK
        // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#integrate-omnisegment-sdk-with-webview-pages
        [OSGWebViewConfigurationExtension addOmniSegmentContentController:configuration];
    }
    
    NSString *source = @"var meta = document.createElement('meta');"
                      "meta.name = 'viewport';"
                      "meta.content = 'viewport-fit=cover, width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';"
                      "document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:source
                                                    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                 forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:userScript];
    
    // Create and configure WebView
    CGRect frame = self.view.bounds;
    self.webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    self.webView.navigationDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.allowsBackForwardNavigationGestures = YES;
    
    [self.view addSubview:self.webView];
    
    // Load URL
    NSURL *url = [NSURL URLWithString:@"https://bebit2.shoplineapp.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // OmniSegment SDK
    // Manually set current page for analytics tracking
    // https://github.com/beBit-tech/bebit-tech-ios-app-sdk/wiki/Usage#set-current-page
    [OmniSegment setCurrentPage:@"Webview"];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"WebView finished loading");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"WebView navigation failed with error: %@", error);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"載入失敗"
                                                                 message:@"無法載入網頁，請檢查網路連線後再試一次。"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"確定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
