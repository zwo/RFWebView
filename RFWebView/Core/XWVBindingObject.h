//
//  XWVBindingObject.h
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/6.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "XWVScriptObject.h"
#import "XWVChannel.h"
@interface XWVBindingObject : XWVScriptObject
@property (strong, nonatomic) id plugin;
@property (weak, nonatomic) XWVChannel *channel;
- (void)invokeNativeMethod:(NSString *)name arguments:(NSArray *)arguments;
- (instancetype)initWithNamespace:(NSString *)aNameSpace channel:(XWVChannel*)channel object:(id)object;
@end
