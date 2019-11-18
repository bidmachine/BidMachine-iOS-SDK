//
//  BDMNativeAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 31/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMNativeAd.h"
#import "BDMDefines.h"

#import "NSError+BDMSdk.h"
#import "BDMNativeAdViewDisplayAd.h"
#import "BDMFactory+BDMDisplayAd.h"
#import "BDMFactory+BDMEventMiddleware.h"

#import <StackFoundation/StackFoundation.h>

@interface BDMNativeAd()<BDMRequestDelegate, BDMDisplayAdDelegate>

@property (nonatomic, strong) BDMEventMiddleware *middleware;
@property (nonatomic, strong) BDMNativeAdRequest *currentRequest;
@property (nonatomic, strong) BDMNativeAdViewDisplayAd *displayAd;

@end

@implementation BDMNativeAd

- (void)makeRequest:(BDMNativeAdRequest *)request {
    NSAssert(BDMNativeAdRequest.stk_isValid(request), @"BDMNativeAd request should be kind of class BDMNativeAdRequest");
    self.middleware = [BDMFactory.sharedFactory middlewareWithRequest:self.currentRequest eventProducer:self];
    self.currentRequest = request;
    switch (self.currentRequest.state) {
        case BDMRequestStateIdle: {
            [self.currentRequest performWithDelegate:self];
            break; }
        case BDMRequestStateSuccessful: {
            [self prepareDisplayAd:self.currentRequest];
            break; }
        case BDMRequestStateFailed: {
            NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"No auction response to load!"];
            [self.delegate nativeAd:self failedWithError:error];
            break; }
        case BDMRequestStateAuction: {
            [self.currentRequest registerDelegate:self];
            break; }
        case BDMRequestStateExpired: {
            NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Auction response was expired"];
            [self.delegate nativeAd:self failedWithError:error];
            break; }
    }
}

- (void)presentOn:(id<BDMNativeAdRendering>)adRendering
       controller:(UIViewController *)controller
            error:(NSError * _Nullable __autoreleasing *)error {
    if (!self.displayAd.hasLoadedCreative) {
        STK_SET_AUTORELASE_VAR(error, [NSError bdm_errorWithCode:BDMErrorCodeNoContent
                                                     description:@"Display ad not ready to present any ad!"])
        return;
    }
    [self.middleware startEvent:BDMEventImpression];
    [self.middleware startEvent:BDMEventClosed];
    [self.middleware startEvent:BDMEventClick];
    [self.middleware startEvent:BDMEventViewable];
    
    [self.currentRequest cancelExpirationTimer];
    //    self.isCreativeOnScreen = YES;
    [self.displayAd presentOn:adRendering controller:controller error:error];
}

- (void)invalidate {
    [self.middleware rejectAll:BDMErrorCodeWasDestroyed];
    [self.currentRequest invalidate];
    [self.displayAd invalidate];
}

- (BOOL)isLoaded {
    return self.displayAd.hasLoadedCreative;
}

- (BOOL)canShow {
    return self.displayAd.availableToPresent;
}

#pragma mark - Private

- (void)prepareDisplayAd:(BDMRequest *)request {
    NSError * error;
    self.displayAd = (BDMNativeAdViewDisplayAd *)[BDMFactory.sharedFactory displayAdWithRequest:self.currentRequest error:&error];
    if (error) {
        [self.delegate nativeAd:self failedWithError:error];
        return;
    }
    
    [self.middleware startEvent:BDMEventCreativeLoading];
    self.displayAd.delegate = self;
    [self.displayAd prepare];
}

#pragma mark - BDMRequestDelegate

- (void)request:(nonnull BDMRequest *)request completeWithInfo:(nonnull BDMAuctionInfo *)info {
    [self prepareDisplayAd:request];
}

- (void)request:(nonnull BDMRequest *)request failedWithError:(nonnull NSError *)error {
    [self.delegate nativeAd:self failedWithError:error];
    
}

- (void)requestDidExpire:(nonnull BDMRequest *)request {
    [self.middleware rejectEvent:BDMEventImpression code:BDMErrorCodeWasExpired];
    if ([self.delegate respondsToSelector:@selector(nativeAdDidExpire:)]) {
        [self.delegate nativeAdDidExpire:self];
    }
    
}

#pragma mark - BDMDisplayAdDelegate

- (void)displayAdReady:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventCreativeLoading];
    [self.delegate nativeAd:self readyToPresentAd:self.auctionInfo];
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedWithError:(NSError *)error {
    [self.middleware rejectEvent:BDMEventCreativeLoading code:error.code];
    [self.delegate nativeAd:self failedWithError:error];
}

- (void)displayAdLogStartView:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventImpression];
    if ([self.producerDelegate respondsToSelector:@selector(didProduceImpression:)]) {
        [self.producerDelegate didProduceImpression:self];
    }
}

- (void)displayAdLogFinishView:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventClosed];
    if ([self.producerDelegate respondsToSelector:@selector(didProduceFinish:)]) {
        [self.producerDelegate didProduceFinish:self];
    }
}

- (void)displayAdLogImpression:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventViewable];
    if ([self.producerDelegate respondsToSelector:@selector(didProduceViewability:)]) {
        [self.producerDelegate didProduceViewability:self];
    }
}

- (void)displayAdLogUserInteraction:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventClick];
    if ([self.producerDelegate respondsToSelector:@selector(didProduceUserAction:)]) {
        [self.producerDelegate didProduceUserAction:self];
    }
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedToPresent:(NSError *)error {
    [self.middleware rejectEvent:BDMEventImpression code:error.code];
    if (error.code != BDMErrorCodeNoConnection) {
        [self invalidate];
    }
}

@end
