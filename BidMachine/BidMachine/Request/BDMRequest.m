//
//  BDMRequest.m
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMRequest.h"
#import "BDMRequest+Private.h"
#import "BDMRequest+HeaderBidding.h"

#import "BDMServerCommunicator.h"

#import "NSError+BDMSdk.h"
#import "BDMSdk+Project.h"
#import "BDMAuctionInfo+Project.h"
#import "BDMFactory+BDMDisplayAd.h"

#import <StackFoundation/StackFoundation.h>
#import "BDMFactory+BDMEventMiddleware.h"

#import "BDMPlacement+Builder.h"

@interface BDMRequest ()

@property (nonatomic, assign) BDMRequestState state;

@property (copy, nonatomic) NSDictionary <NSString *, id> *customParameters;
@property (copy, nonatomic, readwrite, nullable) NSArray <BDMAdNetworkConfiguration *> *networkConfigurations;

@property (copy, nonatomic) NSString *adSpaceId;
@property (copy, nonatomic) NSNumber *activeSegmentIdentifier;
@property (copy, nonatomic) NSNumber *activePlacement;

@property (nonatomic, strong) STKExpirationTimer *expirationTimer;
@property (nonatomic, strong) BDMEventMiddleware *middleware;
@property (nonatomic, strong) NSHashTable <id<BDMRequestDelegate>> *delegates;
@property (nonatomic, copy) id <BDMResponse> response;
@property (nonatomic, copy) BDMPlacement *placement;

@end


@implementation BDMRequest

- (instancetype)init {
    if (self = [super init]) {
        self.state = BDMRequestStateIdle;
    }
    return self;
}

- (void)notifyMediationWin {
    BDMEventURL *url = [BDMEventURL trackerWithStringURL:self.response.lurl type:0];
    [BDMServerCommunicator.sharedCommunicator trackEvent:url];
}

- (void)notifyMediationLoss {
    BDMEventURL *url = [BDMEventURL trackerWithStringURL:self.response.purl type:0];
    [BDMServerCommunicator.sharedCommunicator trackEvent:url];
}

- (NSHashTable<id<BDMRequestDelegate>> *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (void)_performWithRequest:(BDMRequest *)request withPlacement:(BDMPlacement *)placement {
    self.placement = placement;
    
    if (!BDMSdk.sharedSdk.sellerID.length) {
        BDMLog(@"You should call BDMSdk.sharedSdk startSessionWithSellerID:YOUR_SELLER_ID completion:...] before!. Sdk was not initialized properly, see docs: https://wiki.appodeal.com/display/BID/BidMachine+iOS+SDK+Documentation");
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"No seller ID"];
        [self notifyDelegatesOnFail:error];
        return;
    }
    
    if (self.state == BDMRequestStateAuction) {
        BDMLog(@"Trying to perform nonidle request");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [BDMSdk.sharedSdk collectHeaderBiddingAdUnits:self.networkConfigurations
                                        placement:self.placement
                                       completion:^(NSArray<id<BDMPlacementAdUnit>> *placememntAdUnits) {
        // Append header bidding
        id<BDMPlacementRequestBuilder> placementBuilder = [self.placement builder];
        placementBuilder.appendHeaderBidding(placememntAdUnits);
        // Populate targeting
        weakSelf.state = BDMRequestStateAuction;
        [weakSelf.middleware startEvent:BDMEventAuction];
        // Contextual data
        id<BDMContextualProtocol> contextualData = self.contextualData ?: [BDMSdk.sharedSdk.contextualController contextualDataForPlacement:self.placement.type];
        // Make request by expiration timer
        [BDMServerCommunicator.sharedCommunicator makeAuctionRequest:self.timeout
                                                      auctionBuilder:^(BDMAuctionBuilder *builder)
        {
            builder
            .appendPlacementBuilder(placementBuilder)
            .appendPriceFloors(request.priceFloors)
            .appendAuctionSettings(BDMSdk.sharedSdk.auctionSettings)
            .appendSellerID(BDMSdk.sharedSdk.sellerID)
            .appendSessionID(BDMSdk.sharedSdk.contextualController.sessionId)
            .appendTestMode(BDMSdk.sharedSdk.testMode)
            .appendRestrictions(BDMSdk.sharedSdk.restrictions)
            .appendPublisherInfo(BDMSdk.sharedSdk.publisherInfo)
            .appendContextualData(contextualData);
        } success:^(id<BDMResponse> response) {
            // Save response object
            weakSelf.response = response;
            weakSelf.state = BDMRequestStateSuccessful;
            [weakSelf.middleware fulfillEvent:BDMEventAuction];
            [weakSelf saveContextualData];
            [weakSelf beginExpirationMonitoring];
            [weakSelf notifyDelegatesOnSuccess];
        } failure:^(NSError *error) {
            weakSelf.state = BDMRequestStateFailed;
            [weakSelf.middleware rejectEvent:BDMEventAuction code:error.code];
            [weakSelf notifyDelegatesOnFail:error];
        }];
    }];
}

- (BDMAuctionInfo *)info {
    return self.response ? [[BDMAuctionInfo alloc] initWithResponse:self.response] : nil;
}

- (void)_invalidate {
    BDMLog(@"Auction invalidating: %@", self);
    self.expirationTimer = nil;
    self.response = nil;
}

- (void)saveContextualData {
    [BDMSdk.sharedSdk.contextualController registerLastBundle:self.response.creative.bundles.firstObject forPlacement:self.placement.type];
    [BDMSdk.sharedSdk.contextualController registerLastAdomain:self.response.creative.adDomains.firstObject forPlacement:self.placement.type];
}

- (void)beginExpirationMonitoring {
    __weak typeof (self) weakSelf = self;
    BDMLog(@"Started monitoring for expiration for response: %@ of time: %1.2f s", self.response.identifier, self.response.expirationTime.doubleValue);
    [self.middleware startEvent:BDMEventAuctionExpired];
    self.expirationTimer = [STKExpirationTimer expirationTimerWithExpirationTimeinterval:self.response.expirationTime.doubleValue
                                                                          observableItem:self.response
                                                                                  expire:^(id<BDMResponse> response) {
                                                                                      [weakSelf expire];
                                                                                  }];
    [self.expirationTimer fire];
}

- (void)expire {
    [self.middleware fulfillEvent:BDMEventAuctionExpired];
    self.state = BDMRequestStateExpired;
    [self invalidate];
    [self notifyDelegatesOnExpire];
}

- (BDMEventMiddleware *)middleware {
    if (!_middleware) {
        _middleware = [BDMFactory.sharedFactory middlewareWithRequest:self
                                                        eventProducer:nil];
    }
    return _middleware;
}

- (void)setPriceFloors:(NSArray<BDMPriceFloor *> *)priceFloors {
    _priceFloors = priceFloors;
    if (priceFloors.count > 0) {
        BDMLog(@"You haven't disabled header bidding. Are you sure you want to use it with predefined price floor?");
    }
}

#pragma mark - Delegate

- (void)notifyDelegatesOnFail:(NSError *)error {
    for (id<BDMRequestDelegate> delegate in self.delegates.allObjects.reverseObjectEnumerator) {
        [delegate request:self failedWithError:error];
    }
}

- (void)notifyDelegatesOnExpire {
    for (id<BDMRequestDelegate> delegate in self.delegates.allObjects.reverseObjectEnumerator) {
        [delegate requestDidExpire:self];
    }
}

- (void)notifyDelegatesOnSuccess {
    for (id<BDMRequestDelegate> delegate in self.delegates.allObjects.reverseObjectEnumerator) {
        [delegate request:self completeWithInfo:self.info];
    }
}

@end

@implementation BDMRequest (Private)

- (NSArray<BDMEventURL *> *)eventTrackers {
    return self.response.creative.trackers;
}

- (void)registerDelegate:(id<BDMRequestDelegate>)delegate {
    [self.delegates addObject:delegate];
}

- (void)performWithRequest:(BDMRequest *)request withPlacement:(BDMPlacement *)placement {
    [self _performWithRequest:request withPlacement:placement];
}

- (void)invalidate {
    [self.middleware rejectAll:BDMErrorCodeWasDestroyed];
    self.state = BDMRequestStateIdle;
    [self _invalidate];
}

- (void)cancelExpirationTimer {
    BDMLog(@"Cancelling expiration timer for response: %@", self.response.identifier);
    [self.middleware removeEvent:BDMEventAuctionExpired];
    self.expirationTimer = nil;
}

@end


@implementation BDMRequest (DisplayAd)

- (id<BDMDisplayAd>)displayAdWithError:(NSError *__autoreleasing *)error {
    if (self.state != BDMRequestStateSuccessful) {
        STK_SET_AUTORELASE_VAR(error, [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"Request was not successful. Cannot create display ad!"]);
    }
    return [BDMFactory.sharedFactory displayAdWithResponse:self.response
                                             plecementType:self.placement.type];
}

@end
