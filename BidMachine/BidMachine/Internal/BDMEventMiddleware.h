//
//  BDMEventMidleware.h
//  BidMachine
//
//  Created by Stas Kochkin on 28/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDMAdEventProducerProtocol.h"
#import "BDMDefines.h"
#import "BDMRequest+Private.h"

@class BDMEventURL;

typedef NS_ENUM(NSInteger, BDMEvent) {
    BDMEventCreativeLoading = 500,
    BDMEventImpression = 501,
    BDMEventViewable = 502,
    BDMEventClick = 503,
    BDMEventClosed = 504,
    BDMEventDestroyed = 505,
    BDMEventInitialisation = 506,
    BDMEventAuction = 507,
    BDMEventAuctionExpired = 509,
    BDMEventAuctionDestroyed = 510,
    BDMEventHeaderBiddingNetworkInitializing = 701,
    BDMEventHeaderBiddingNetworkPreparing = 702,
    BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared = 703
};

@interface BDMEventMiddlewareBuilder : NSObject

@property (nonatomic, copy, readonly) BDMEventMiddlewareBuilder *(^events)(NSArray <BDMEventURL *>*(^)(void));
@property (nonatomic, copy, readonly) BDMEventMiddlewareBuilder *(^producer)(id<BDMAdEventProducer>(^)(void));

@end

@interface BDMEventMiddleware : NSObject

+ (instancetype)buildMiddleware:(void(^)(BDMEventMiddlewareBuilder *))build;

- (void)rejectAll:(BDMErrorCode)code;

- (void)startEvent:(BDMEvent)type;
- (void)startEvent:(BDMEvent)type
         placement:(BDMInternalPlacementType)placement;
- (void)startEvent:(BDMEvent)type
           network:(NSString *)network;
- (void)startEvent:(BDMEvent)type
         placement:(BDMInternalPlacementType)placement
           network:(NSString *)network;

- (void)fulfillEvent:(BDMEvent)type;
- (void)fulfillEvent:(BDMEvent)type
             network:(NSString *)network;
- (void)fulfillEvent:(BDMEvent)type
           placement:(BDMInternalPlacementType)placement;
- (void)fulfillEvent:(BDMEvent)type
           placement:(BDMInternalPlacementType)placement
             network:(NSString *)network;

- (void)rejectEvent:(BDMEvent)type
               code:(BDMErrorCode)code;
- (void)rejectEvent:(BDMEvent)type
            network:(NSString *)network
               code:(BDMErrorCode)code;
- (void)rejectEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
               code:(BDMErrorCode)code;
- (void)rejectEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
            network:(NSString *)network
               code:(BDMErrorCode)code;

- (void)removeEvent:(BDMEvent)type;
- (void)removeEvent:(BDMEvent)type
            network:(NSString *)network;
- (void)removeEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement;
- (void)removeEvent:(BDMEvent)type
          placement:(BDMInternalPlacementType)placement
            network:(NSString *)network;

@end

