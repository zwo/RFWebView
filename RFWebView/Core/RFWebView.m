//
//  RFWebView.m
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/2.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "RFWebView.h"
#import "XWVChannel.h"
@import CoreFoundation;
@implementation RFWebView

- (void)loadPlugin:(id)object namespace:(NSString *)aNamespace
{
    XWVChannel *channel=[[XWVChannel alloc] initWithWebView:self];
    [channel bindPlugin:object toNamespace:aNamespace];
}

- (void)asyncEvaluateJavaScript:(NSString *_Nonnull)script completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))handler
{
    if ([NSThread isMainThread]) {
        [self evaluateJavaScript:script completionHandler:handler];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self evaluateJavaScript:script completionHandler:handler];
        });
    }
}

- (id _Nullable)syncEvaluateJavaScript:(NSString *_Nonnull)script
{
    __block id result;
    __block NSError *err;
    __block BOOL done=NO;
    NSTimeInterval timeout=3.0;
    if ([NSThread isMainThread]) {
        [self evaluateJavaScript:script completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            result=obj;
            err=error;
            done = YES;
        }];
        while (!done) {
            CFRunLoopRunResult reason = CFRunLoopRunInMode(kCFRunLoopDefaultMode, timeout, true);
            if (reason != kCFRunLoopRunHandledSource) {
                break;
            }
        }
    } else {
        NSCondition *condition = [[NSCondition alloc]init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self evaluateJavaScript:script completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                [condition lock];
                result=obj;
                err=error;
                done=true;
                [condition signal];
                [condition unlock];
            }];
        });
        [condition lock];
        while (!done) {
            if (![condition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeout]]) {
                break;
            }
        }
        [condition unlock];
    }
    if (err) {
        NSLog(@"error evaluate js %@",err.localizedDescription);
    }
    if (!done) {
        NSLog(@"!Timeout to evaluate script: %@", script);
    }
    return result;
}

- (void)prepareForPlugin
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"xwebview" ofType:@"js"];
    NSString *source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *script=[[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [self.configuration.userContentController addUserScript:script];
    if (self.URL != nil) {
        [self evaluateJavaScript:script.source completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            if (error) {
                NSLog(@"!Failed to inject script.%@",error.localizedDescription);
            }
        }];
    }
}
@end
