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
@synthesize currentAudioTime = _currentAudioTime;
@synthesize slider = _slider;
@synthesize playBarItems = _playBarItems;
@synthesize pauseBarItems = _pauseBarItems;
@synthesize audioArray = _audioArray;
@synthesize toolBar = _toolBar;
@synthesize segmentControl = _segmentControl;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_segmentControl release];
    [_toolBar release];
    [_playBarItems release];
    [_pauseBarItems release];
    [_audioArray release];
    [_currentAudioTime release];
    [_slider release];
    [_currentAudio release];
    [_tableView release];
    [_token release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [_segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed) name:KSPlayerConnectionFailedNotification object:nil];
    [self.navigationItem setHidesBackButton:YES];
    [_slider setHidden:YES];
    [KSPlayer sharedInstance].delegate = self;
    [super viewDidLoad];
    self.audioArray = [NSMutableArray array];
    [self getAudioFromServer:kUsersMusic];
    
    [self setupToolBarWithPlaying:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

#pragma mark - Notification

- (void)connectionFailed
{
    NSLog(@"connection failed");
    UIAlertView *noInetrnet = [[UIAlertView alloc] initWithTitle: @"VK Player" message: @"No Internet"
            delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    
    [noInetrnet show];
    [noInetrnet release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[KSPlayer sharedInstance] pause];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype)
    {
        case UIEventSubtypeRemoteControlTogglePlayPause:
        {
            if([[KSPlayer sharedInstance] rate] == 0)
            {
                [[KSPlayer sharedInstance] playAudio:_currentAudio];
            } else
            {
                [[KSPlayer sharedInstance] pauseAudio];
            }
            break;
        }
        case UIEventSubtypeRemoteControlPlay:
        {
            [[KSPlayer sharedInstance] playAudio:_currentAudio];
            break;
        }
        case UIEventSubtypeRemoteControlPause:
        {
            [[KSPlayer sharedInstance] pauseAudio];
            break;
        }
        default:
            break;
    }
}

#pragma mark - API

- (void)getAudioFromServer:(NSString *)whichMusic
{
    [[KSServerManager sharedManager] getAudioWithOffset: [self.audioArray count]
                                                  token: _token
                                                  limit: kCountToLoad
                                             whichMusic: whichMusic
                                              onSuccess: ^(NSArray *audioList) {
                                                  if (audioList == nil)
                                                  {
                                                      [self clearAccessData];
                                                      [self.navigationController popViewControllerAnimated:YES];
                                                  }
                                                  else
                                                  {
                                                      [self.audioArray addObjectsFromArray:audioList];
                                                      self.currentLoadedAudios += [audioList count];
                                                      [_tableView reloadData];
                                                  }
                            
                                              } onFailure:^(NSError *error, NSInteger statusCode) {
                                                  NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
                                              }];
}

- (void)setBroadcast
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isBroadcast"])
    {
        [[KSServerManager sharedManager] setBroadcast:_currentAudio
                                            onSuccess:^(NSArray *response) {
                                                NSLog(@"Broadcast");
                                            }
                                            onFailure:^(NSError *error, NSInteger statusCode) {
                                                NSLog(@"Error with updating status");
                                            }];
    }
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
        [self loadNewMusicPart];
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
    [_slider setValue:0.0 animated:YES];
    [_slider setHidden:NO];
    [self setupToolBarWithPlaying:YES];
    _currentAudio = [self.audioArray objectAtIndex:indexPath.row];
    _currentAudioIndex = indexPath.row;
    [self playAndUpdateSlider];
}

#pragma mark - ToolbarActions

- (IBAction)logOut:(id)sender
{
    NSLog(@"log out");
    
    [[KSPlayer sharedInstance] stopAudio];
    [self clearAccessData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)playAudio:(id)sender
{
    NSLog(@"playAudio");
    
    [_slider setHidden:NO];
    [self setupToolBarWithPlaying:YES];
    
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
        [self loadNewMusicPart];
    }
    if (self.currentAudioIndex != [self.audioArray count] - 1)
    {
        [_slider setValue:0.0 animated:YES];
        [self setupToolBarWithPlaying:YES];
        
        [[KSPlayer sharedInstance] stopAudio];
        _currentAudio = [self.audioArray objectAtIndex: (++self.currentAudioIndex)];
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
        [_slider setValue:0.0 animated:YES];
        [[KSPlayer sharedInstance] stopAudio];
        _currentAudio = [self.audioArray objectAtIndex: (--self.currentAudioIndex)];
        [self selectRowAtIndex:_currentAudioIndex];
    }
}

- (void)playAndUpdateSlider
{
    [self setBroadcast];
    [_slider setMaximumValue:_currentAudio.duration.intValue];
    [[KSPlayer sharedInstance] playAudio: _currentAudio];
}

- (void)clearAccessData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:kAccessToken];
    [defaults setObject:nil forKey:kUserID];
    [defaults synchronize];
}

- (IBAction)pauseAudio:(id)sender
{
    [self setupToolBarWithPlaying:NO];
    [[KSPlayer sharedInstance] pauseAudio];
}

- (IBAction)valueChangeSliderTimer:(id)sender
{
    NSLog(@"start changing");
    [[KSPlayer sharedInstance] seekToTime:_slider.value];
}

- (void)updateTimeLabel:(unsigned long long)current_second
{
    UInt64 minutes = current_second / 60;
    UInt64 seconds = current_second % 60;
    _currentAudioTime.title = [NSString stringWithFormat: @"%02llu:%02llu", minutes, seconds];
}

- (void)setupToolBarWithPlaying:(BOOL)isPlaying
{
    [_toolBar setItems:(isPlaying) ? _pauseBarItems : _playBarItems];
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


#pragma mark - SegmentControl

- (void)segmentControlChanged:(id)sender
{
    NSLog(@"%d", [_segmentControl selectedSegmentIndex]);
    [_tableView setDataSource:nil];
    
    if([_segmentControl selectedSegmentIndex] == 0)
    {
        [self updateTableWithData:kUsersMusic];
    }
    else if ([_segmentControl selectedSegmentIndex] == 1)
    {
        [self updateTableWithData:kPopularMusic];
    }
    else if ([_segmentControl selectedSegmentIndex] == 2)
    {
        [self updateTableWithData:kRecommendationMusic];
    }
}

- (void)updateTableWithData:(NSString *)data
{
    [_tableView setDataSource:self];
    self.currentAudioIndex = 0;
    self.currentLoadedAudios = 0;
    [self.audioArray removeAllObjects];
    [self getAudioFromServer:data];
}

- (void)loadNewMusicPart
{
    if([_segmentControl selectedSegmentIndex] == 0) // my music
    {
        [self getAudioFromServer:kUsersMusic];
    }
    else if ([_segmentControl selectedSegmentIndex] == 1) // popular music
    {
        [self getAudioFromServer:kPopularMusic];
    }
    else if ([_segmentControl selectedSegmentIndex] == 2) // recommended music
    {
        [self getAudioFromServer:kRecommendationMusic];
    }
}

@end
