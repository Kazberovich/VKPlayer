//
//  KSViewController.h
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNetworkStatusHelper.h"

@class KSAccessToken;

@interface KSViewController : UIViewController <UIWebViewDelegate, NetworkStatusDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) IBOutlet UIView *noConnectionView;
@property (nonatomic, retain) IBOutlet UILabel *noConnectionLabel;

@end
