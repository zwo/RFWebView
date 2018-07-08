//
//  XWVMetaObject.m
//  RFWebView
//
//  Created by 周维鸥 on 2018/7/6.
//  Copyright © 2018年 周维鸥. All rights reserved.
//

#import "XWVMetaObject.h"

@implementation XWVMetaObjectMember

- (instancetype)initWithMethodSelector:(SEL)selector arity:(int)arity
{
	self=[super init];
	if (self)
	{
		self.memberType=XWVMetaObjectMemberMethod;
		self.selector=selector;
		self.arity=arity;
	}
	return self;
}

- (instancetype)initWithPropertyGetter:(SEL)getter setter:(SEL)setter
{
	self=[super init];
	if (self)
	{
		self.memberType=XWVMetaObjectMemberProperty;
		self.getter=getter;
		self.setter=setter;
	}
	return self;
}

- (instancetype)initWithInitializerSelector:(SEL)selector arity:(int)arity
{
	self=[super init];
	if (self)
	{
		self.memberType=XWVMetaObjectMemberInitializer;
		self.selector=selector;
		self.arity=arity;
	}
	return self;
}

- (BOOL)isMethod
{
	return self.memberType==XWVMetaObjectMemberMethod;
}

- (BOOL)isProperty
{
	return self.memberType==XWVMetaObjectMemberProperty;
}

- (BOOL)isInitializer
{
	return self.memberType==XWVMetaObjectMemberInitializer;
}

- (NSString*)type
{
	BOOL promise=false;
	int arity=-1;
	if (self.memberType=XWVMetaObjectMemberMethod)
	{
		NSString *selString=NSStringFromSelector(self.selector);
		promise = [selString hasSuffix:@":promiseObject:"] || [selString hasSuffix:@"PromiseObject:"];
		arity = self.arity;
	}else if (self.memberType=XWVMetaObjectMemberInitializer)
	{
		promise=true;
		arity = self.arity<0?self.arity:(self.arity+1);
	}
	if (!promise && arity<0)
	{
		return @"";
	}
	NSString *ret=@"#";
	if (arity>=0)
	{
		ret=[ret stringByAppendingFormat:@"%zd",arity];
	}
	if (promise)
	{
		ret=[ret stringByAppendingString:@"p"];
	}else{
		ret=[ret stringByAppendingString:@"a"];
	}
	return ret;
}


@end

@implementation XWVMetaObject

@end
