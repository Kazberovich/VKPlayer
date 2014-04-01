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
@property (nonatomic, retain) id playbackObserver;

@end

@implementation KSPlayer

@synthesize currentAudio = _currentAudio;
@synthesize audioPlayer = _audioPlayer;
@synthesize playbackObserver = _playbackObserver;

- (void)dealloc
{
    [_playbackObserver release];
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
        
        _playbackObserver = [self.audioPlayer addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time) {
            UInt64 currentTimeSec = self.audioPlayer.currentTime.value / self.audioPlayer.currentTime.timescale;
            [self.delegate playerCurrentTime:currentTimeSec];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:)
            name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        [self.audioPlayer play];
    }
    else
    {
        [self.audioPlayer play];
    }
}

- (void)itemDidFinishPlaying:(NSNotification *)notification
{
    [self.delegate playerDidFinishPlayingItem];
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

- (void)seekToTime:(float)second
{
    [self.audioPlayer removeTimeObserver:_playbackObserver];
    
    [_audioPlayer seekToTime:CMTimeMake(second * 1000, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    CMTime interval = CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC);
    __block int i = 0;
    _playbackObserver = [self.audioPlayer addPeriodicTimeObserverForInterval:interval queue:nil usingBlock:^(CMTime time) {
        UInt64 currentTimeSec = self.audioPlayer.currentTime.value / self.audioPlayer.currentTime.timescale;
        //workaround. ignore jumping to previous slider's position
        if(i > 2)
        {
            [self.delegate playerCurrentTime:currentTimeSec];
        }
        i++;
    }];
}

@end
