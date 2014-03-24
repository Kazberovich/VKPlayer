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

static const NSInteger kCountToLoad = 20;
// offset from the bottom of playlist to load new block of music
static const NSInteger kOffsetFromTheBottom = 5;

@synthesize tableView = _tableView;
@synthesize token = _token;
@synthesize currentAudio = _currentAudio;

- (void)dealloc
{
    [_currentAudio release];
    [_tableView release];
    [_token release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [KSPlayer sharedInstance].delegate = self;
    [super viewDidLoad];
    self.audioArray = [NSMutableArray array];
    [self getAudioFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

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
    if (indexPath.row == [self.audioArray count])
    {
        [self getAudioFromServer];
    }
    else
    {
        _currentAudio = [self.audioArray objectAtIndex:indexPath.row];
        _currentAudioIndex = indexPath.row;
    }
}

#pragma mark - ToolbarActions

- (IBAction)playAudio:(id)sender
{
    NSLog(@"playAudio");
    if (self.currentAudioIndex)
    {
        [[KSPlayer sharedInstance] playAudio:_currentAudio];
    }
    else
    {
        _currentAudioIndex = 0;
        _currentAudio = [self.audioArray objectAtIndex:_currentAudioIndex];
        [[KSPlayer sharedInstance] playAudio:_currentAudio];
        [self selectRowAtIndex:_currentAudioIndex];
    }
}

- (IBAction)nextAudio:(id)sender
{
    [[KSPlayer sharedInstance] stopAudio];
    NSLog(@"nextAudio");
    if(_currentAudioIndex == [self.audioArray count] - kOffsetFromTheBottom)
    {
        [self getAudioFromServer];
    }
    _currentAudio = [self.audioArray objectAtIndex: (++self.currentAudioIndex)];
    [[KSPlayer sharedInstance] playAudio: _currentAudio];
    [self selectRowAtIndex:_currentAudioIndex];
}

- (IBAction)previousAudio:(id)sender
{
    NSLog(@"previousAudio");
    
    if ((int)_currentAudioIndex >= 1)
    {
        [[KSPlayer sharedInstance] stopAudio];
        _currentAudio = [self.audioArray objectAtIndex: (--self.currentAudioIndex)];
        [[KSPlayer sharedInstance] playAudio: _currentAudio];
        [self selectRowAtIndex:_currentAudioIndex];
    }
}

- (IBAction)pauseAudio:(id)sender
{
    [[KSPlayer sharedInstance] pauseAudio];
}

#pragma mark - KSPlayerDelegate

- (void)playerCurrentTime:(NSString *)time
{
    NSLog(@"playerCurrentTime = %@", time);
    self.currentAudioTime.title = time;
}

@end
