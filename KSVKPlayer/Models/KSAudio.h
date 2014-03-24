//
//  KSAudio.h
//  KSVKPlayer
//
//  Created by mac-214 on 20.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSAudio : NSObject

@property (nonatomic, retain) NSString *aid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *duration;
@property (nonatomic, retain) NSString *genre;

- (id)initWithServerResponse:(NSDictionary *)responseObject;

@end
