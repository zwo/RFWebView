//
//  RFWebAPI.m
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/10.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "RFWebAPI.h"

@implementation RFWebAPI
- (void)showAlert
{
    NSLog(@"%s",__func__);
}
- (void)twoArgsOne:(NSString *)one two:(NSString *)two
{
    NSLog(@"%s %@ %@",__func__, one, two);
}
- (void)RFN_GetUserInfoWithCallbackFunctionName:(NSString *)jsFuncName
{
    NSLog(@"%s %@",__func__, jsFuncName);
}
- (void)RFN_GetOpenUIDWithTicket:(NSString *)ticket callbackFunctionName:(NSString *)jsFuncName
{
    NSLog(@"%s %@ %@",__func__, ticket, jsFuncName);
}

- (void)RFN_OpenBrowser:(NSString *)URLString
{
    NSLog(@"%s %@",__func__, URLString);
}
@end
