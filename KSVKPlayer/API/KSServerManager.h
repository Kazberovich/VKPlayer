//
//  KSServerManager.h
//  KSVKPlayer
//
//  Created by mac-214 on 20.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KSAccessToken;
@class KSAudio;

#define kUsersMusic @"audio.get"
#define kPopularMusic @"audio.getPopular"
#define kRecommendationMusic @"audio.getRecommendations"

@interface KSServerManager : NSObject

+ (KSServerManager *)sharedManager;

- (void)getAudioWithOffset:(NSInteger)offset
                      token:(KSAccessToken *)token
                      limit:(NSInteger)count
                whichMusic:(NSString *)kindOfMusic
                  onSuccess:(void(^)(NSArray *audioList))success
                  onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;

- (void)setBroadcast:(KSAudio *)audio
           onSuccess:(void(^)(NSArray *response))success
           onFailure:(void(^)(NSError *error, NSInteger statusCode))failure;
@end