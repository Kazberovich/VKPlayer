//
//  KSURLBuilder.m
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSURLBuilder.h"

@implementation KSURLBuilder

+ (NSString *)getAuthorizeURL
{
    //66568 - bitmask = offline(+65536) = audio(+8) = status(+1024)
    NSString *fullUrl = [self append:kAuthorizeURL, @"?", @"client_id=", kClientID, @"&", @"redirect_uri=", kRedirectURI, @"&", @"display=mobile", @"&scope=66568&response_type=token&revoke=1", nil];
    return fullUrl;
}

+ (NSString *)append:(id) first, ...
{
    NSString *result = @"";
    id eachArg;
    va_list alist;
    if(first)
    {
    	result = [result stringByAppendingString:first];
    	va_start(alist, first);
    	while((eachArg = va_arg(alist, id)))
        {
    		result = [result stringByAppendingString:eachArg];
        }
    	va_end(alist);
    }
    NSLog(@"%@", result);
    return result;
}

@end
