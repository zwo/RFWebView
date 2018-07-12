//
//  XWVBindingObject.m
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/6.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "XWVBindingObject.h"
#import <objc/runtime.h>
@implementation XWVBindingObject

- (instancetype)initWithNamespace:(NSString *)aNameSpace channel:(XWVChannel *)channel object:(id)object
{
    self=[super initWithNamespace:aNameSpace webView:channel.webView];
    if (self) {
        self.channel=channel;
        self.plugin=object;
    }
    return self;
}

- (void)invokeNativeMethod:(NSString *)name arguments:(NSArray *)arguments
{
    NSString *selName=[self.channel.typeInfo objectForKey:name];
    SEL selector = NSSelectorFromString(selName);
    [self performSelector:selector arguments:arguments waitUntilDone:NO];
}

- (void)performSelector:(SEL)aSelector arguments:(NSArray *)args waitUntilDone:(BOOL)wait
{
    dispatch_block_t block = ^{
        Method method = class_getInstanceMethod([self.plugin class], aSelector);
        NSMethodSignature* sig = [[self.plugin class] instanceMethodSignatureForSelector:aSelector];
        if (!sig) {
            NSException *e= [[NSException alloc] initWithName:@"unrecognized selector" reason:[NSString stringWithFormat:@"unrecognized selector %@ sent to %@",NSStringFromSelector(aSelector),self.plugin] userInfo:nil];
            @throw e;
        }
        if (args.count+2 > method_getNumberOfArguments(method)) {
            NSException *e= [[NSException alloc] initWithName:@"too many arguments" reason:[NSString stringWithFormat:@"too many arguments for selector %@ sent to %@",NSStringFromSelector(aSelector),self.plugin] userInfo:nil];
            @throw e;
        }
        NSInvocation* invoker = [NSInvocation invocationWithMethodSignature:sig];
        invoker.selector = aSelector;
        invoker.target = self.plugin;
        for (int i=0; i<args.count; i++) {
            id arg = args[i];
            const char *code = [sig getArgumentTypeAtIndex:i+2];
            char icode=*code;
            // See: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
            if (icode==0x63 || icode==0x69 || icode==0x73 || icode==0x6c || icode==0x71 || icode==0x43 || icode==0x49 || icode==0x53 || icode==0x4c || icode==0x51) { // int or char or long
                NSInteger integerValue = [arg integerValue];
                [invoker setArgument:&integerValue atIndex:i+2];
            }else if (icode==0x64 || icode==0x66) {
                double doubleValue = [arg doubleValue];
                [invoker setArgument:&doubleValue atIndex:i+2];
            }else if (icode == 0x42) {
                BOOL boolValue = [arg boolValue];
                [invoker setArgument:&boolValue atIndex:i+2];
            }else if (icode == 0x40) {
                [invoker setArgument:&arg atIndex:i+2];
            }else{
                NSException *e= [[NSException alloc] initWithName:@"unsupported argument type" reason:[NSString stringWithFormat:@"unsupported argument type %i",icode] userInfo:nil];
                @throw e;
            }
        }
        [invoker retainArguments];
        [invoker invoke];
    };
    if (dispatch_get_specific(self.channel.queueTag))
        block();
    else
        dispatch_sync(self.channel.queue, block);
}
@end
