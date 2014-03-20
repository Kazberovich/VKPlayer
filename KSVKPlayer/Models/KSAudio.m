//
//  KSAudio.m
//  KSVKPlayer
//
//  Created by mac-214 on 20.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSAudio.h"

@implementation KSAudio

- (void) dealloc
{
    [self.aid release];
    [self.title release];
    [self.artist release];
    [self.genre release];
    [self.duration release];
    [self.url release];
    
    [super dealloc];
}

- (id) initWithServerResponse:(NSDictionary*) responseObject
{
    self = [super init];
    if (self) {
        self.aid = [responseObject objectForKey:@"aid"];
        self.title = [responseObject objectForKey:@"title"];
        self.artist = [responseObject objectForKey:@"artist"];
        self.genre = [responseObject objectForKey:@"genre"];
        self.duration = [responseObject objectForKey:@"duration"];
        self.url = [responseObject objectForKey:@"url"];
    }
    return self;
}

@end
