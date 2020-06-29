//
//  BDMApiRequest.h
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMAuctionBuilder.h"
#import "BDMSessionBuilder.h"

@interface BDMApiRequest : NSMutableURLRequest

+ (BDMApiRequest *)request:(NSNumber *)timeout builder:(void(^)(BDMAuctionBuilder *))build;
+ (BDMApiRequest *)sessionRequest:(NSNumber *)timeout builder:(void(^)(BDMSessionBuilder *))build;

@end
