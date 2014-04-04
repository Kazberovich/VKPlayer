//
//  KSNetworkStatusHelper.m
//  KSVKPlayer
//
//  Created by mac-214 on 03.04.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSNetworkStatusHelper.h"
#import "Reachability.h"

@implementation KSNetworkStatusHelper

@synthesize isNetworkConnection = _isNetworkConnection;

+ (KSNetworkStatusHelper *)sharedInstance
{
    static KSNetworkStatusHelper *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (BOOL)isInternetActive
{
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    return (netStatus == ReachableViaWWAN || netStatus == ReachableViaWiFi) ? YES : NO;
}

@end
