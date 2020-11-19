//
//  BDMSessionBuilder.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BDMTargeting.h"


@class GPBMessage;

@interface BDMSessionBuilder : NSObject

@property (nonatomic, readonly) GPBMessage *message;
@property (nonatomic, readonly) NSURL *baseURL;

- (BDMSessionBuilder *(^)(NSURL *))appendBaseURL;
- (BDMSessionBuilder *(^)(NSString *))appendSellerID;
- (BDMSessionBuilder *(^)(NSString *))appendSessionID;
- (BDMSessionBuilder *(^)(BDMTargeting *))appendTargeting;

@end
