//
//  BDMRequest+Private.h
//  BidMachine
//
//  Created by Stas Kochkin on 11/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMRequest.h"
#import "BDMDefines.h"
#import "BDMPlacementRequestBuilderProtocol.h"

@class BDMEventURL;

typedef NS_ENUM(NSInteger, BDMRequestState) {
    BDMRequestStateIdle = 0,
    BDMRequestStateAuction,
    BDMRequestStateSuccessful,
    BDMRequestStateFailed,
    BDMRequestStateExpired
};

@interface BDMRequest (Private)

@property (nonatomic, assign, readonly) BDMInternalPlacementType placementType;
@property (nonatomic, assign, readonly) BDMRequestState state;
@property (nonatomic, copy, readonly) NSArray<BDMEventURL *> *eventTrackers;

- (void)performWithRequest:(BDMRequest *)request
             placementType:(BDMInternalPlacementType)placementType
          placementBuilder:(id<BDMPlacementRequestBuilder>)placementBuilder;
- (void)registerDelegate:(id<BDMRequestDelegate>)delegate;
- (void)cancelExpirationTimer;
- (void)invalidate;

@end

@interface BDMRequest (DisplayAd)

- (id)displayAdWithError:(NSError *__autoreleasing *)error;

@end
