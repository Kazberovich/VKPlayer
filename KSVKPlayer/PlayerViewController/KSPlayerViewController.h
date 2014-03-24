//
//  KSPlayerViewController.h
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KSAccessToken;

@interface KSPlayerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) KSAccessToken *token;

- (IBAction)playAudio:(id)sender;
- (IBAction)nextAudio:(id)sender;
- (IBAction)previousAudio:(id)sender;
- (IBAction)pauseAudio:(id)sender;

@end
