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
    NSString *fullUrl = [self append:kAuthorizeURL, @"?", @"client_id=", kClientID, @"&", @"redirect_uri=", kRedirectURI, @"&", @"display=mobile", @"&scope=audio&response_type=token&revoke=1", nil];
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
