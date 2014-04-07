//
//  KSAppDelegate.h
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface KSAppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate>

@property (retain, nonatomic) UIWindow *window;

@end
