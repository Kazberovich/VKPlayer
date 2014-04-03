//
//  KSPlayerDeleagate.h
//  KSVKPlayer
//
//  Created by mac-214 on 24.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPlayer.h"

@protocol KSPlayerDelegate <NSObject>

- (void)playerCurrentTime:(unsigned long long)time_in_seconds;
- (void)playerDidFinishPlayingItem;
- (void)playerInternetConnectionFailed;

@end
