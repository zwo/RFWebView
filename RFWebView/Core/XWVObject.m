//
//  XWVObject.m
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/2.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "XWVObject.h"
#import "XWVScriptObject.h"
@interface XWVObject ()
@property (weak, nonatomic) XWVObject *origin;
@property (nonatomic) NSInteger reference;
@end

@implementation XWVObject
- (instancetype)initWithNamespace:(NSString *)namespace  webView:(RFWebView *)webView
{
    self=[super init];
    if (self) {
        self.namespace=namespace;
        self.webView=webView;
        self.reference=0;
        self.origin=self;
    }
    return self;
}

- (instancetype)initWithNamespace:(NSString *)namespace  origin:(XWVObject *)origin
{
    self=[super init];
    if (self) {
        self.namespace=namespace;
        self.origin=origin;
        self.webView=origin.webView;
        self.reference=0;
    }
    return self;
}

- (instancetype)initWithReference:(NSInteger)reference  origin:(XWVObject *)origin
{
    self=[super init];
    if (self) {
        self.reference=reference;
        self.origin=origin;
        self.webView=origin.webView;
        self.namespace=[NSString stringWithFormat:@"%@.$references[%zd]",origin.namespace,reference];
    }
    return self;
}

- (void)dealloc
{
    if (!self.webView) {
        return;
    }
    NSString *script;
    if (self.origin == self) {
        script=[NSString stringWithFormat:@"delete %@",self.namespace];
    }else if (self.reference!=0 && self.origin!=nil) {
        script=[NSString stringWithFormat:@"%@.$releaseObject(%zd)",self.origin.namespace,self.reference];
    }else{
        return;
    }
    [self.webView asyncEvaluateJavaScript:script completionHandler:nil];
}

- (id)evaluateExpression:(NSString *)expression
{
    if (!self.webView) {
        @throw [NSException exceptionWithName:@"nil webview" reason:@"not associate with a webview" userInfo:nil];
    }
    id result=[self.webView syncEvaluateJavaScript:[self scriptForRetaining:expression]];
    return [self wrapScriptObject:result];
}

- (void)evaluateExpression:(NSString *)expression completionHandler:(void (^)(id, NSError *))completionHandler
{
    if (!self.webView) {
        if (completionHandler) {
            completionHandler(nil,[NSError errorWithDomain:WKErrorDomain code:WKErrorWebViewInvalidated userInfo:nil]);
        }
        return;
    }
    if (!completionHandler) {
        [self.webView asyncEvaluateJavaScript:expression completionHandler:nil];
        return;
    }
    XWVObject __weak *weakSelf = self;
    [self.webView asyncEvaluateJavaScript:[self scriptForRetaining:expression] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            completionHandler(nil,error);
        }else if (result) {
            completionHandler([weakSelf wrapScriptObject:result]?:result,nil);
        }else{
            completionHandler(nil,nil);
        }
    }];
}

- (NSString *)scriptForRetaining:(NSString *)script
{
    if (self.origin) {
        return [NSString stringWithFormat:@"%@.$retainObject(%@)",self.origin.namespace,script];
    }
    return script;
}

- (id)wrapScriptObject:(id)object;
{
    if (self.origin) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict=object;
            NSNumber *num=dict[@"$sig"];
            if ([num isKindOfClass:[NSNumber class]] && num.integerValue==0x5857574F) {
                NSNumber *num2=dict[@"$ref"];
                if ([num2 isKindOfClass:[NSNumber class]] && num2.integerValue!=0 ) {
                    return [[XWVScriptObject alloc] initWithReference:num2.integerValue origin:self.origin];
                }else if ([dict[@"$ns"] isKindOfClass:[NSString class]]) {
                    NSString *namespace=dict[@"$ns"];
                    return [[XWVScriptObject alloc] initWithNamespace:namespace origin:self.origin];
                }
            }
        }
    }
    return object;
}

- (NSString *)jsonString
{
    return self.namespace;
}
@end
