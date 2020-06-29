//
//  BDMServerCommunicator.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMResponseProtocol.h"
#import "BDMDefines.h"
#import "BDMRequest.h"
#import "BDMEventURL.h"
#import "BDMAuctionBuilder.h"
#import "BDMSessionBuilder.h"
#import "BDMPlacementRequestBuilderProtocol.h"
#import "BDMInitialisationResponseProtocol.h"


@interface BDMServerCommunicator : NSObject

+ (instancetype)sharedCommunicator;

- (void)makeAuctionRequest:(NSNumber *)timeout
            auctionBuilder:(void(^)(BDMAuctionBuilder *builder))auctionBuilder
                   success:(void(^)(id<BDMResponse>))success
                   failure:(void(^)(NSError *))failure;

- (void)makeInitRequest:(NSNumber *)timeout
         sessionBuilder:(void(^)(BDMSessionBuilder *builder))sessionBuilder
                success:(void(^)(id<BDMInitialisationResponse>))success
                failure:(void(^)(NSError *))failure;

- (void)trackEvent:(BDMEventURL *)tracker
           success:(void(^)(void))success
           failure:(void(^)(NSError *))failure;

- (void)trackEvent:(BDMEventURL *)tracker;

@end
