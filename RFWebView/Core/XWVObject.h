//
//  XWVObject.h
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/2.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;
#import "RFWebView.h"

typedef void (^XWVObjectHandler)(id,NSError*);

@protocol XWVObjectJSONProtocol
- (NSString *)jsonString;
@end

@interface XWVObject : NSObject <XWVObjectJSONProtocol>
@property (strong, nonatomic) NSString *namespace;
@property (weak, nonatomic) RFWebView *webView;
- (instancetype)initWithNamespace:(NSString *)namespace  webView:(RFWebView *)webView;
- (instancetype)initWithNamespace:(NSString *)namespace  origin:(XWVObject *)origin;
- (instancetype)initWithReference:(NSInteger)reference  origin:(XWVObject *)origin;
- (id)evaluateExpression:(NSString *)expression;
- (void)evaluateExpression:(NSString *)expression completionHandler:(void (^)(id, NSError*))completionHandler;

@end
