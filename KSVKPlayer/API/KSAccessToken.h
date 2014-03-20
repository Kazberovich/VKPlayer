//
//  KSAccessToken.h
//  KSVKPlayer
//
//  Created by mac-214 on 19.03.14.
//  Copyright (c) 2014 mac-214. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSAccessToken : NSObject

@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSDate *expirationDate;
@property (nonatomic, retain) NSString *userID;

@end
