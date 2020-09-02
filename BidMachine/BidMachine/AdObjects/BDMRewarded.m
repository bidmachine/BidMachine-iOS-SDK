//
//  BDMRewarded.m
//  BidMachine
//
//  Created by Stas Kochkin on 16/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMRewarded.h"
#import "BDMRequest+HeaderBidding.h"
#import "BDMRequest+Private.h"
#import "BDMFactory+BDMEventMiddleware.h"
#import "BDMFactory+BDMDisplayAd.h"
#import "BDMSdkConfiguration+HeaderBidding.h"
#import "BDMSdk+Project.h"
#import "NSError+BDMSdk.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMRewarded () <BDMRequestDelegate, BDMDisplayAdDelegate>

@property (nonatomic, strong) BDMEventMiddleware *middleware;
@property (nonatomic, strong) id <BDMDisplayAd> displayAd;

@property (nonatomic, strong) BDMRewardedRequest *currentRequest;

@end

@implementation BDMRewarded

#pragma mark - Public

- (void)makeRequest:(BDMRequest *)request {
    [self populateWithRequest:(BDMRewardedRequest *)request];
}

- (void)populateWithRequest:(BDMRewardedRequest *)request {
    NSAssert(BDMRewardedRequest.stk_isValid(request), @"BDMRewarded request should be kind of class BDMRewardedRequest");
    self.currentRequest = request;
    self.middleware = [BDMFactory.sharedFactory middlewareWithRequest:self.currentRequest eventProducer:self];
    switch (self.currentRequest.state) {
        case BDMRequestStateIdle: {
            [self.currentRequest performWithDelegate:self];
            break; }
        case BDMRequestStateSuccessful: {
            [self prepareDisplayAd];
            break; }
        case BDMRequestStateFailed: {
            NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"No auction response to load!"];
            [self.delegate rewarded:self failedWithError:error];
            break; }
        case BDMRequestStateAuction: {
            [self.currentRequest registerDelegate:self];
            break; }
        case BDMRequestStateExpired: {
            NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Auction response was expired"];
            [self.delegate rewarded:self failedWithError:error];
            break; }
    }
}

- (BOOL)isLoaded {
    return self.displayAd.hasLoadedCreative;
}

- (BOOL)canShow {
    return self.displayAd.availableToPresent;
}

- (BDMAuctionInfo *)auctionInfo {
    return self.currentRequest.info;
}

- (UIView *)adView {
    return self.displayAd.adView;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (!self.displayAd.hasLoadedCreative) {
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent
                                         description:@"Display ad not ready to present any ad!"];
        [self.delegate rewarded:self failedToPresentWithError:error];
        return;
    }
    
    [self.middleware startEvent:BDMEventImpression];
    [self.middleware startEvent:BDMEventClosed];
    [self.middleware startEvent:BDMEventClick];
    [self.middleware startEvent:BDMEventViewable];
    
    [self.currentRequest cancelExpirationTimer];
    [self.displayAd presentAd:rootViewController container:nil];
}

#pragma mark - Private

- (void)prepareDisplayAd {
    NSError *error;
    self.displayAd = [BDMFactory.sharedFactory displayAdWithRequest:self.currentRequest error:&error];
    if (error) {
        [self.delegate rewarded:self failedWithError:error];
        return;
    }
    
    [self.middleware startEvent:BDMEventCreativeLoading];
    self.displayAd.delegate = self;
    [self.displayAd prepare];
}

- (void)invalidate {
    [self.middleware rejectAll:BDMErrorCodeWasDestroyed];
    [self.currentRequest invalidate];
    [self.displayAd invalidate];
    self.currentRequest = nil;
    self.displayAd = nil;
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    [self prepareDisplayAd];
}

- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    [self.delegate rewarded:self failedWithError:error];
}

- (void)requestDidExpire:(BDMRequest *)request {
    [self.middleware rejectEvent:BDMEventImpression code:BDMErrorCodeWasExpired];
    if ([self.delegate respondsToSelector:@selector(rewardedDidExpire:)]) {
        [self.delegate rewardedDidExpire:self];
    }
}

#pragma mark - BDMDisplayAdDelegate

- (void)displayAdReady:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventCreativeLoading];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    if ([self.delegate respondsToSelector:@selector(rewarded:readyToPresentAd:)]) {
        [self.delegate rewarded:self readyToPresentAd:self.auctionInfo];
    }
#pragma clang diagnostic pop
    [self.delegate rewardedReadyToPresent:self];
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedWithError:(NSError *)error {
    [self.middleware rejectEvent:BDMEventCreativeLoading code:error.code];
    [self.delegate rewarded:self failedWithError:error];
}

- (void)displayAdLogImpression:(id<BDMDisplayAd>)displayAd {}

- (void)displayAdLogUserInteraction:(id<BDMDisplayAd>)displayAd {
    [BDMSdk.sharedSdk.contextualController registerClickForPlacement:self.currentRequest.placementType];
    [self.middleware fulfillEvent:BDMEventClick];
    [self.delegate rewardedRecieveUserInteraction:self];
}

- (void)displayAdLogStartView:(id<BDMDisplayAd>)displayAd {
    [BDMSdk.sharedSdk.contextualController registerImpressionForPlacement:self.currentRequest.placementType];
    [self.middleware fulfillEvent:BDMEventImpression];
    [self.delegate rewardedWillPresent:self];
}

- (void)displayAdLogFinishView:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventClosed];
    [self.delegate rewardedDidDismiss:self];
    [self invalidate];
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedToPresent:(NSError *)error {
    [self.middleware rejectEvent:BDMEventImpression code:error.code];
    [self.delegate rewarded:self failedToPresentWithError:error];
    if (error.code != BDMErrorCodeNoConnection) {
        [self invalidate];
    }
}

- (void)displayAdCompleteRewardAction:(id<BDMDisplayAd>)displayAd {
    [BDMSdk.sharedSdk.contextualController registerCompletionForPlacement:self.currentRequest.placementType];
    [self.middleware fulfillEvent:BDMEventViewable];
    [self.delegate rewardedFinishRewardAction:self];
}

@end
