//
//  KSURLBuilder.h
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kClientID @"4253161"
#define kAuthorizeURL @"https://oauth.vk.com/authorize"
#define kRedirectURI @"https://oauth.vk.com/blank.html"

@interface KSURLBuilder : NSObject

+ (NSString*)getAuthorizeURL;

@end
