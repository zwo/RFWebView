//
//  XWVScriptObject.m
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/3.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "XWVScriptObject.h"

@implementation XWVScriptObject

- (void)constructWithArguments:(NSArray *)arguments completionHandler:(XWVObjectHandler)completionHandler
{
    NSString *expr=[NSString stringWithFormat:@"new %@",[self expressionForMethod:nil arguments:arguments]];
    [self evaluateExpression:expr completionHandler:completionHandler];
}

- (void)callWithArguments:(NSArray *)arguments completionHandler:(XWVObjectHandler)completionHandler
{
    NSString *expr=[self expressionForMethod:nil arguments:arguments];
    [self evaluateExpression:expr completionHandler:completionHandler];
}

- (void)callMethod:(NSString*)name arguments:(NSArray *)arguments completionHandler:(XWVObjectHandler)completionHandler
{
    NSString *expr=[self expressionForMethod:name arguments:arguments];
    [self evaluateExpression:expr completionHandler:completionHandler];
}
// synchronized method calling
- (XWVScriptObject*)constructWithArguments:(NSArray *)arguments
{
    NSString *expr=[NSString stringWithFormat:@"new %@",[self expressionForMethod:nil arguments:arguments]];
    id result=[self evaluateExpression:expr];
    if ([result isKindOfClass:[XWVScriptObject class]]) {
        return result;
    }
    @throw [NSError errorWithDomain:WKErrorDomain code:WKErrorJavaScriptExceptionOccurred userInfo:nil];
    return nil;
}

- (id)callWithArguments:(NSArray *)arguments
{
    return [self evaluateExpression:[self expressionForMethod:nil arguments:arguments]];
}

- (id)callMethod:(NSString*)name arguments:(NSArray *)arguments
{
    return [self evaluateExpression:[self expressionForMethod:name arguments:arguments]];
}

- (id)defineProperty:(NSString *)name descriptor:(NSDictionary *)descriptor;
{
    NSString *json=[XWVScriptObject jsonify:descriptor];
    NSString *expr=[NSString stringWithFormat:@"Object.defineProperty(%@, %@, %@)",self.namespace, name, json];
    return [self evaluateExpression:expr];
}

- (BOOL)deleteProperty:(NSString *)name
{
    NSString *expr=[self expressionForProperty:name];
    expr=[NSString stringWithFormat:@"delete %@",expr];
    id result=[self evaluateExpression:expr];
    if ([result isKindOfClass:[NSNumber class]]) {
        return [result boolValue];
    }
    return NO;
}

- (BOOL)hasProperty:(NSString *)name
{
    NSString *expr=[NSString stringWithFormat:@"%@ != undefined",[self expressionForProperty:name]];
    id result=[self evaluateExpression:expr];
    if ([result isKindOfClass:[NSNumber class]]) {
        return [result boolValue];
    }
    return NO;
}

- (id)valueForName:(NSString *)name
{
    id result=[self expressionForProperty:name];
    id obj=[self evaluateExpression:result];
    return obj;
}

- (void)setValue:(id)value forName:(NSString *)name;
{
    NSString *json=[XWVScriptObject jsonify:value];
    NSString *script=[self expressionForProperty:name];
    script=[NSString stringWithFormat:@"%@=%@",script,json];
    [self.webView asyncEvaluateJavaScript:script completionHandler:nil];
}

- (id)valueAtIndex:(NSInteger)index
{
    NSString *expr=[NSString stringWithFormat:@"%@[%zd]",self.namespace,index];
    return [self evaluateExpression:expr];
}

- (void)setValue:(id)value atIndex:(NSInteger)index
{
    NSString *json=[XWVScriptObject jsonify:value];
    NSString *script=[NSString stringWithFormat:@"%@[%zd]=%@",self.namespace,index,json];
    [self.webView asyncEvaluateJavaScript:script completionHandler:nil];
}

- (NSString *)expressionForProperty:(NSString *)name
{
    if (name==nil) {
        return self.namespace;
    }
    if (name.length==0) {
        return [NSString stringWithFormat:@"%@['']",self.namespace];
    }else{
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([name rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            // name consists only of the digits 0 through 9
            NSInteger idx=[name integerValue];
            return [NSString stringWithFormat:@"%@[%zd]",self.namespace, idx];
        }
        return [NSString stringWithFormat:@"%@.%@",self.namespace,name];
    }
}

- (NSString *)expressionForMethod:(NSString *)name arguments:(NSArray *)arguments
{
    NSMutableArray *args=[NSMutableArray arrayWithCapacity:arguments.count];
    for (id obj in arguments) {
        [args addObject:[XWVScriptObject jsonify:obj]];
    }
    NSString *joinedString=[args componentsJoinedByString:@", "];
    NSString *ret=[NSString stringWithFormat:@"%@(%@)",[self expressionForProperty:name],joinedString];
    return ret;
}

+ (NSString *)jsonify:(id)value
{
    if (!value) {
        return @"undefined";
    }else if ([value isKindOfClass:[NSNull class]]) {
        return @"null";
    }else if ([value isKindOfClass:[NSString class]]) {
        return value;
    }else if ([value isKindOfClass:[NSNumber class]]) {
        if (strcmp([(NSNumber*)value objCType], @encode(BOOL)) == 0) {
            if ([(NSNumber*)value boolValue]) {
                return @"true";
            } else {
                return @"false";
            }
        } else{
            return [(NSNumber*)value stringValue];
        }
    }else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        NSError *error;
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:value options:0 error:&error];
        NSString *jsonString=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString=[jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        if (!jsonString) {
            return @"null";
        } else {
            return jsonString;
        }
    }else if ([value conformsToProtocol:@protocol(XWVObjectJSONProtocol)]) {
        return [value jsonString];
    }
    return @"";
}
@end
