//
//  RFWebAPI.h
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/10.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFWebAPI : NSObject
- (void)showAlert;
- (void)twoArgsOne:(NSString *)one two:(NSString *)two;
- (void)RFN_GetUserInfoWithCallbackFunctionName:(NSString *)jsFuncName;
- (void)RFN_GetOpenUIDWithTicket:(NSString *)ticket callbackFunctionName:(NSString *)jsFuncName;
@end
