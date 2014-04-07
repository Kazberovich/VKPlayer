//
//  KSPlayer.h
//  KSVKPlayer
//
//  Created by mac-214 on 21.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KSPlayerViewController.h"
#import "Reachability.h"

extern NSString* const KSPlayerConnectionFailedNotification;

@protocol KSPlayerDelegate;
@class KSAudio;

@interface KSPlayer : AVQueuePlayer

@property (nonatomic, retain) KSAudio *currentAudio;
@property (nonatomic, assign) id <KSPlayerDelegate> delegate;

+ (KSPlayer *)sharedInstance;
- (void)playAudio:(KSAudio *)audio;
- (void)pauseAudio;
- (void)stopAudio;
- (void)seekToTime:(float)second;

@end
