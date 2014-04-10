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
@property (nonatomic, retain) IBOutlet UISlider *slider;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *currentAudioTime;
@property (nonatomic, retain) IBOutletCollection(UIBarButtonItem) NSArray *playBarItems;
@property (nonatomic, retain) IBOutletCollection(UIBarButtonItem) NSArray *pauseBarItems;

@property (nonatomic, retain) KSAccessToken *token;

- (IBAction)logOut:(id)sender;
- (IBAction)playAudio:(id)sender;
- (IBAction)nextAudio:(id)sender;
- (IBAction)previousAudio:(id)sender;
- (IBAction)pauseAudio:(id)sender;
- (IBAction)valueChangeSliderTimer:(id)sender;
- (IBAction)stopAudio:(id)sender;

@end
