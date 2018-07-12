//
//  XWVChannel.m
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/6.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "XWVChannel.h"
#import <objc/runtime.h>
#import "XWVBindingObject.h"

@interface XWVChannel ()

@property (strong, nonatomic) NSString *identifier;
@property (nonatomic, strong) NSRunLoop *runLoop;
@property (strong, nonatomic) XWVBindingObject *principal;

@end

@implementation XWVChannel

- (instancetype)initWithWebView:(RFWebView *)webView
{
    self=[super init];
    if (self) {
        self.webView=webView;
        _queueTag=&_queueTag;
        _queue = dispatch_queue_create("com.rfchina.webview", NULL);
        dispatch_queue_set_specific(_queue, _queueTag, _queueTag, NULL);
        [webView prepareForPlugin];
    }
    return self;
}

- (void)bindPlugin:(id)object toNamespace:(NSString *)aNamespace
{
    self.identifier = [NSString stringWithFormat:@"%i",[XWVChannel sequenceNumber]];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:self.identifier];
    [self fetchMethodsFromObject:object];
    self.principal=[[XWVBindingObject alloc] initWithNamespace:aNamespace channel:self object:object];
    WKUserScript *script=[[WKUserScript alloc] initWithSource:[self generateStubs] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [self.webView.configuration.userContentController addUserScript:script];
    if (self.webView.URL != nil) {
        [self.webView evaluateJavaScript:script.source completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"!Failed to inject script. %@",error.localizedDescription);
            }
        }];
    }
}

- (void)fetchMethodsFromObject:(id)object
{
    _typeInfo=[NSMutableDictionary dictionaryWithCapacity:16];
    unsigned int count = 0;
    Method *methods = class_copyMethodList([object class], &count);
    for (unsigned int i = 0; i < count; ++i) {
        SEL sel = method_getName(methods[i]);
        NSString *selName = NSStringFromSelector(sel);
        NSString *name=selName;
        NSArray *comp=[selName componentsSeparatedByString:@":"];
        if ([comp count]>1) {
            name=[comp firstObject];
        }
        [_typeInfo setObject:selName forKey:name];
    }
    free(methods);
}

- (NSString *)generateStubs
{
    NSArray *allKeys=[self.typeInfo allKeys];
    NSMutableString *muString = [NSMutableString stringWithString:@""];
    for (NSString *key in allKeys) {
        NSString *method=[self generateMethod:key this:@"exports"];
        [muString appendFormat:@"%@\n",method];
    }
    NSString *base=@"function(){return XWVPlugin.invokeNative.bind(arguments.callee, \'\').apply(null, arguments);}";
    NSString *ret=[NSString stringWithFormat:@"(function(exports) {\n%@})(XWVPlugin.createPlugin('%@', '%@', %@));\n", muString, self.identifier, self.principal.namespace, base];
    return ret;
}

- (NSString *)generateMethod:(NSString *)key this:(NSString *)thisJS
{
    NSString *stub = [NSString stringWithFormat:@"XWVPlugin.invokeNative.bind(%@, %@)",thisJS, key];
    stub = [NSString stringWithFormat:@"%@;", stub];
    return stub;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDictionary *body=message.body;
    NSString *opcode = body[@"$opcode"];
    if (!opcode) {
        NSLog(@"-Unknown message: %@",body);
        return;
    }
    NSArray *args=body[@"$operand"];
    [self.principal invokeNativeMethod:opcode arguments:args];
}

+ (uint)sequenceNumber
{
    static uint _number=0;
    _number++;
    return _number;
}
@end
