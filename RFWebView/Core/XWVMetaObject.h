//
//  XWVMetaObject.h
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/6.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
typedef NS_ENUM(NSInteger, XWVMetaObjectMemberType) {
    XWVMetaObjectMemberMethod,//默认从0开始
    XWVMetaObjectMemberProperty,
    XWVMetaObjectMemberInitializer,
};

@interface XWVMetaObjectMember : NSObject
@property (nonatomic, assign) XWVMetaObjectMemberType memberType;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) SEL getter;
@property (nonatomic, assign) SEL setter;
@property (nonatomic, assign) int arity;
- (instancetype)initWithMethodSelector:(SEL)selector arity:(int)arity;
- (instancetype)initWithPropertyGetter:(SEL)getter setter:(SEL)setter;
- (instancetype)initWithInitializerSelector:(SEL)selector arity:(int)arity;
- (BOOL)isMethod;
- (BOOL)isProperty;
- (BOOL)isInitializer;
- (NSString*)type;
@end

@interface XWVMetaObject : NSObject
@property (nonatomic, assign) Class plugin;
@property (nonatomic, strong) NSDictionary *members;
- (instancetype)initWithPlugin:(Class)plugin;
@end
