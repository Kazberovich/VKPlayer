//
//  KSPlayer.m
//  KSVKPlayer
//
//  Created by mac-214 on 21.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSPlayer.h"
#import "KSAudio.h"

@interface KSPlayer()

@property (nonatomic, retain) AVPlayer* audioPlayer;

@end


@implementation KSPlayer
@synthesize currentAudio = _currentAudio;
@synthesize audioPlayer = _audioPlayer;

- (void) dealloc
{
    [_currentAudio release];
    [_audioPlayer release];
    [super dealloc];
}

+ (KSPlayer*) sharedInstance
{
    static KSPlayer* player = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[KSPlayer alloc] init];
    });
    return player;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"oo");
    }
    return self;
}

- (void) playAudio:(KSAudio *)audio
{
    if (_currentAudio != audio) {
        
        [_audioPlayer pause];
        
        _currentAudio = audio;
        
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:_currentAudio.url]];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        _audioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        
        CMTime interval = CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC); // 1 second
        [_audioPlayer addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time) {
            NSLog(@"change");
        }];
        [_audioPlayer play];
    }
    else
    {
        [_audioPlayer play];
    }
}

- (void) pauseAudio
{
    [_audioPlayer pause];
}


-(void)itemDidChangeCurrentTime {
    NSLog(@"itemDidChangeCurrentTime");
}


@end
