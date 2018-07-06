//
//  XWVScriptObject.h
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/3.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "XWVObject.h"

@interface XWVScriptObject : XWVObject
- (void)constructWithArguments:(NSArray *)arguments completionHandler:(XWVObjectHandler)completionHandler;
- (void)callWithArguments:(NSArray *)arguments completionHandler:(XWVObjectHandler)completionHandler;
- (void)callMethod:(NSString*)name arguments:(NSArray *)arguments completionHandler:(XWVObjectHandler)completionHandler;
// synchronized method calling
- (XWVScriptObject*)constructWithArguments:(NSArray *)arguments;
- (id)callWithArguments:(NSArray *)arguments;
- (id)callMethod:(NSString*)name arguments:(NSArray *)arguments;

- (id)defineProperty:(NSString *)name descriptor:(NSDictionary *)descriptor;
- (BOOL)deleteProperty:(NSString *)name;
- (BOOL)hasProperty:(NSString *)name;
- (id)valueForName:(NSString *)name;
- (void)setValue:(id)value forName:(NSString *)name;
- (id)valueAtIndex:(NSInteger)index;
- (void)setValue:(id)value atIndex:(NSInteger)index;
+ (NSString *)jsonify:(id)value;
@end
