//
//  KSPlayer.m
//  KSVKPlayer
//
//  Created by mac-214 on 21.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSPlayer.h"
#import "KSAudio.h"
#import "KSPlayerDelegate.h"

@interface KSPlayer()

@property (nonatomic, retain) AVQueuePlayer *audioPlayer;

@end

@implementation KSPlayer
@synthesize currentAudio = _currentAudio;

- (void)dealloc
{
    [_currentAudio release];
    [super dealloc];
}

+ (KSPlayer *)sharedInstance
{
    static KSPlayer *player = nil;
    
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
        NSLog(@"Init");
    }
    return self;
}

- (void)playAudio:(KSAudio *)audio
{
    if (_currentAudio != audio)
    {
        NSLog(@"play new audio");
        [self stopAudio];
        [_currentAudio retain];
        _currentAudio = audio;
        
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:_currentAudio.url]] ;
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        self.audioPlayer = [AVQueuePlayer playerWithPlayerItem:playerItem];
        
        CMTime interval = CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC);
        [self.audioPlayer addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time) {
            
            UInt64 currentTimeSec = self.audioPlayer.currentTime.value / self.audioPlayer.currentTime.timescale;
            UInt32 minutes = currentTimeSec / 60;
            UInt32 seconds = currentTimeSec % 60;
            [self.delegate playerCurrentTime:[NSString stringWithFormat: @"%02d:%02d", minutes, seconds]];
        }];
       
        [self.audioPlayer play];
    }
    else
    {
        [self.audioPlayer play];
    }
}

- (void)pauseAudio
{
    NSLog(@"pause");
    [self.audioPlayer pause];
}

- (void)stopAudio
{
    NSLog(@"stop");
    [self.audioPlayer removeAllItems];
    self.audioPlayer = nil;
}

- (void)itemDidChangeCurrentTime
{
    NSLog(@"itemDidChangeCurrentTime");
}

@end
