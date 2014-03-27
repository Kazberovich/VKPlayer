//
//  KSPlayerViewController.m
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSPlayerViewController.h"
#import "KSAccessToken.h"
#import "KSServerManager.h"
#import "KSAudio.h"
#import "KSPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "KSPlayerDelegate.h"

@interface KSPlayerViewController ()

@property (nonatomic, retain) NSMutableArray *audioArray;
@property (nonatomic, retain) KSAudio *currentAudio;
@property int currentAudioIndex;
@property int currentLoadedAudios;

@end

@implementation KSPlayerViewController

// offset from the bottom of playlist to load new block of music
static const NSInteger kOffsetFromTheBottom = 5;
static const NSInteger kCountToLoad = 20;

@synthesize tableView = _tableView;
@synthesize token = _token;
@synthesize currentAudio = _currentAudio;
@synthesize slider = _slider;

- (void)dealloc
{
    [_slider release];
    [_currentAudio release];
    [_tableView release];
    [_token release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [self.navigationItem setHidesBackButton:YES];
    [_slider setHidden:YES];
    [KSPlayer sharedInstance].delegate = self;
    [super viewDidLoad];
    self.audioArray = [NSMutableArray array];
    [self getAudioFromServer];
}

#pragma mark - API

- (void)getAudioFromServer
{
    [[KSServerManager sharedManager] getAudioWithOffset: [self.audioArray count]
                                                  token: _token
                                                  limit: kCountToLoad
     
                                              onSuccess: ^(NSArray *audioList) {
                                                  [self.audioArray addObjectsFromArray:audioList];
                                                  self.currentLoadedAudios += kCountToLoad;
                                                  [_tableView reloadData];
                            
                                              } onFailure:^(NSError *error, NSInteger statusCode) {
                                                  NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
                                              }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.audioArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
    
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
    }
    
    if (indexPath.row == self.currentLoadedAudios - 1)
    {
        [self getAudioFromServer];
    }
    else
    {
        KSAudio *audio = [self.audioArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", audio.title];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", audio.artist];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)selectRowAtIndex:(int)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_slider setHidden:NO];
    _currentAudio = [self.audioArray objectAtIndex:indexPath.row];
    _currentAudioIndex = indexPath.row;
    [self playAndUpdateSlider];
}

#pragma mark - ToolbarActions

- (IBAction)logOut:(id)sender
{
    NSLog(@"log out");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:kAccessToken];
    [defaults setObject:nil forKey:kUserID];
    [defaults synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)playAudio:(id)sender
{
    NSLog(@"playAudio");
    
    [_slider setHidden:NO];
    
    if (self.currentAudioIndex)
    {
        [self playAndUpdateSlider];
    }
    else
    {
        _currentAudioIndex = 0;
        _currentAudio = [self.audioArray objectAtIndex:_currentAudioIndex];
        [self playAndUpdateSlider];
        [self selectRowAtIndex:_currentAudioIndex];
    }
}

- (IBAction)nextAudio:(id)sender
{
    NSLog(@"nextAudio");
    
    [_slider setHidden:NO];
    
    
    if(_currentAudioIndex == [self.audioArray count] - kOffsetFromTheBottom)
    {
        [self getAudioFromServer];
    }
    if (self.currentAudioIndex != [self.audioArray count] - 1)
    {
        [[KSPlayer sharedInstance] stopAudio];
        _currentAudio = [self.audioArray objectAtIndex: (++self.currentAudioIndex)];
        [self playAndUpdateSlider];
        [self selectRowAtIndex:_currentAudioIndex];
    }
    else
    {
        [[KSPlayer sharedInstance] pauseAudio];
    }
}

- (IBAction)previousAudio:(id)sender
{
    NSLog(@"previousAudio");
    
    [_slider setHidden:NO];
    
    if ((int)_currentAudioIndex >= 1)
    {
        [[KSPlayer sharedInstance] stopAudio];
        _currentAudio = [self.audioArray objectAtIndex: (--self.currentAudioIndex)];
        [self playAndUpdateSlider];
        [self selectRowAtIndex:_currentAudioIndex];
    }
}

- (void)playAndUpdateSlider
{
    [_slider setMaximumValue:_currentAudio.duration.intValue];
    [[KSPlayer sharedInstance] playAudio: _currentAudio];
}

- (IBAction)pauseAudio:(id)sender
{
    [[KSPlayer sharedInstance] pauseAudio];
}

- (IBAction)valueChangeSliderTimer:(id)sender
{
    [[KSPlayer sharedInstance] seekToTime:_slider.value];
}

- (void)updateTimeLabel:(unsigned long long)current_second
{
    UInt64 minutes = current_second / 60;
    UInt64 seconds = current_second % 60;
    _currentAudioTime.title = [NSString stringWithFormat: @"%02llu:%02llu", minutes, seconds];
}

#pragma mark - KSPlayerDelegate

- (void)playerCurrentTime:(unsigned long long)current_second
{
    NSLog(@"playerCurrentTime = %llu", current_second);
    
    [_slider setValue:current_second animated:YES];
    [self updateTimeLabel:current_second];
}

- (void)playerDidFinishPlayingItem
{
    [self nextAudio:nil];
}

@end
