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

static KSNetworkStatusHelper *sNetworkStatusHelper = nil;

+ (KSNetworkStatusHelper *)sharedInstance
{
    @synchronized(self)
    {
        if(sNetworkStatusHelper == nil)
        {
            sNetworkStatusHelper = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return sNetworkStatusHelper;
}

- (void)dealloc
{
    if (self.reachability)
    {
        [self.reachability stopNotifier];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_reachability release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:)name:kReachabilityChangedNotification object:nil];
            self.reachability = [Reachability reachabilityForInternetConnection];
            [self.reachability startNotifier];
    }
    return self;
}

- (void)handleNetworkChange:(NSNotification*) notice
{
    NetworkStatus remoteHostStatus = [self.reachability currentReachabilityStatus];
    if(remoteHostStatus == NotReachable)
    {
        NSLog(@"no Internet");
        _isNetworkConnection = NO;
        [self.delegate statusWasChanged:self];
    }
    else if(remoteHostStatus == ReachableViaWiFi)
    {
        NSLog(@"wifi");
        _isNetworkConnection = YES;
        [self.delegate statusWasChanged:self];
    }
    else if(remoteHostStatus == ReachableViaWWAN)
    {
        NSLog(@"3G");
        _isNetworkConnection = YES;
        [self.delegate statusWasChanged:self];
    }
}

+ (BOOL)isInternetActive
{
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"Access Not Available");
            return NO;
        }
        
        case ReachableViaWWAN:
        {
            NSLog(@"Reachable WWAN");
            return YES;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"Reachable WiFi");
            return YES;
        }
    }
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)autorelease
{
    return self;
}

@end
