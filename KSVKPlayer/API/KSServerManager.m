//
//  KSServerManager.m
//  KSVKPlayer
//
//  Created by mac-214 on 20.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import "KSServerManager.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "KSAccessToken.h"
#import "KSAudio.h"

@interface KSServerManager ()

@property (nonatomic, retain) AFHTTPRequestOperationManager* requestOperationManager;

@end

@implementation KSServerManager

+ (KSServerManager *)sharedManager
{
    static KSServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KSServerManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSURL *url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.requestOperationManager = [[[AFHTTPRequestOperationManager alloc] initWithBaseURL:url] autorelease];
    }
    return self;
}

- (void) getAudioWithOffset:(NSInteger) offset
                      token:(KSAccessToken *) token
                      limit:(NSInteger) count
                  onSuccess:(void(^)(NSArray *audioList)) success
                  onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            token.userID, @"uid",
                            @(count), @"count",
                            @(offset), @"offset",
                            token.token, @"access_token", nil];
    
    [self.requestOperationManager GET:@"audio.get"
                           parameters:params
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSLog(@"JSON: %@", responseObject);
                                  
                                  if([responseObject objectForKey:@"error"])
                                  {
                                      success(nil);
                                  }
                                  else
                                  {
                                      NSArray *audioArray = [responseObject objectForKey:@"response"];
                                      NSMutableArray *objectsArray = [NSMutableArray array];
                                      
                                      for (NSDictionary *audioDictionary in audioArray)
                                      {
                                          KSAudio *audio = [[KSAudio alloc] initWithServerResponse:audioDictionary];
                                          [objectsArray addObject:audio];
                                          [audio release];
                                      }
                                      
                                      if(success)
                                      {
                                          success(objectsArray);
                                      }
                                  }
                              }
     
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  NSLog(@"Error: %@", error);
                                  if (failure) {
                                      failure(error, operation.response.statusCode);
                                  }
                              }];
}

- (void)setBroadcast:(KSAudio *) audio
           onSuccess:(void(^)(NSArray *response)) success
           onFailure:(void(^)(NSError *error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSUserDefaults standardUserDefaults]objectForKey:kAccessToken], @"access_token",
                            [NSString stringWithFormat:@"%d_%d",audio.ownerID.intValue, audio.aid.intValue], @"audio", //owner_id_audio_id
                            nil];
    
    [self.requestOperationManager GET:@"audio.setBroadcast"
                           parameters:params
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  NSLog(@"JSON: %@", responseObject);
                                  
                                  if([responseObject objectForKey:@"error"])
                                  {
                                      success(nil);
                                  }
                              }
     
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  NSLog(@"Error: %@", error);
                                  if (failure) {
                                      failure(error, operation.response.statusCode);
                                  }
                              }];
}

@end
