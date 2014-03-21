//
//  KSPlayer.h
//  KSVKPlayer
//
//  Created by mac-214 on 21.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class KSAudio;

@interface KSPlayer : AVPlayer

@property (nonatomic, retain) KSAudio* currentAudio;

+ (KSPlayer*) sharedInstance;
- (void) playAudio:(KSAudio*) audio;
- (void) pauseAudio;

@end
