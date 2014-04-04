//
//  KSNetworkStatusHelper.h
//  KSVKPlayer
//
//  Created by mac-214 on 03.04.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;
@protocol NetworkStatusDelegate;

@interface KSNetworkStatusHelper : NSObject

@property (nonatomic, retain) Reachability *reachability;
@property (nonatomic, retain) id <NetworkStatusDelegate> delegate;
@property (nonatomic, assign) BOOL isNetworkConnection;

+ (KSNetworkStatusHelper *)sharedInstance;
+ (BOOL)isInternetActive;

@end

@protocol NetworkStatusDelegate

@required

- (void)statusWasChanged:(KSNetworkStatusHelper *)helper;

@end
