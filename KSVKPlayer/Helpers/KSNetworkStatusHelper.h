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

@property (nonatomic, assign) BOOL isNetworkConnection;

+ (KSNetworkStatusHelper *)sharedInstance;
+ (BOOL)isInternetActive;

@end
