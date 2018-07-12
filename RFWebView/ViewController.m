//
//  ViewController.m
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/2.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "ViewController.h"
#import "RFWebView.h"
#import "RFWebAPI.h"
@interface ViewController ()
@property (strong, nonatomic) RFWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView=[[RFWebView alloc] initWithFrame:self.view.frame configuration:[WKWebViewConfiguration new]];
    [self.view addSubview:self.webView];
    [self.webView loadPlugin:[RFWebAPI new] namespace:@"sample.RFWebAPI"];
    
    NSURL *fileURL=[[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    if (@available(iOS 9.0, *)) {
        [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
