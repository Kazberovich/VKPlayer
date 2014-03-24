//
//  KSPlayerViewController.h
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSPlayerDelegate.h"

@class KSAccessToken;
@protocol KSPlayerDelegate;

@interface KSPlayerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KSPlayerDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *currentAudioTime;
@property (nonatomic, retain) KSAccessToken *token;

- (IBAction)playAudio:(id)sender;
- (IBAction)nextAudio:(id)sender;
- (IBAction)previousAudio:(id)sender;
- (IBAction)pauseAudio:(id)sender;

@end
