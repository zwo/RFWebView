//
//  XWVChannel.h
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/6.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;
@interface XWVChannel : NSObject <WKScriptMessageHandler>
@property (strong, nonatomic) NSString *identifier;
@property (nonatomic, strong) NSRunLoop *runLoop;
@property (nonatomic, strong) dispatch_queue_t queue;
@end
