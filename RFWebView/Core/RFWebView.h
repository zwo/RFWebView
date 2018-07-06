//
//  RFWebView.h
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/2.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface RFWebView : WKWebView
- (void)asyncEvaluateJavaScript:(NSString *_Nonnull)script completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))handler;
- (id _Nullable)syncEvaluateJavaScript:(NSString *_Nonnull)script;
@end
