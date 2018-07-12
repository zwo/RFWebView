//
//  XWVChannel.h
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/6.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;
#import "RFWebView.h"
@interface XWVChannel : NSObject <WKScriptMessageHandler>
@property (nonatomic, weak) RFWebView *webView;
@property (strong, nonatomic) NSMutableDictionary *typeInfo;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic) void *queueTag;
- (instancetype)initWithWebView:(RFWebView *)webView;
- (void)bindPlugin:(id)object toNamespace:(NSString *)aNamespace;
@end
