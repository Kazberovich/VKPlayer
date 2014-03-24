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
@synthesize audioPlayer = _audioPlayer;

- (void)dealloc
{
    [_audioPlayer release];
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

- (void)playAudio:(KSAudio *)audio
{
    if (_currentAudio != audio)
    {
        NSLog(@"play new audio");
        [self stopAudio];
        
        self.currentAudio = audio;
        
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:_currentAudio.url]] ;
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        self.audioPlayer = [AVQueuePlayer playerWithPlayerItem:playerItem];
        
        CMTime interval = CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC);
        [self.audioPlayer addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time) {
            
            UInt64 currentTimeSec = self.audioPlayer.currentTime.value / self.audioPlayer.currentTime.timescale;
            UInt64 minutes = currentTimeSec / 60;
            UInt64 seconds = currentTimeSec % 60;
            [self.delegate playerCurrentTime:[NSString stringWithFormat: @"%02llu:%02llu", minutes, seconds]];
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

@end
