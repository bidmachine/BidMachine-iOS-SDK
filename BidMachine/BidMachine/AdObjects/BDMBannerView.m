//
//  BDMBannerView.m
//  BidMachine
//
//  Created by Stas Kochkin on 10/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMBannerView.h"
#import "BDMRequest+HeaderBidding.h"
#import "BDMRequest+Private.h"
#import "BDMFactory+BDMEventMiddleware.h"
#import "BDMFactory+BDMDisplayAd.h"
#import "NSError+BDMSdk.h"
#import "BDMSdkConfiguration+HeaderBidding.h"
#import "BDMSdk+Project.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMBannerView () <BDMRequestDelegate, BDMDisplayAdDelegate>

@property (nonatomic, strong) BDMEventMiddleware *middleware;
@property (nonatomic, strong) id <BDMDisplayAd> displayAd;

@property (nonatomic, assign) BOOL isCreativeOnScreen;
@property (nonatomic, strong) BDMBannerRequest *currentRequest;

@end

@implementation BDMBannerView

- (instancetype)init {
    if (self = [super init]) {
        [self configureAppearance];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureAppearance];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureAppearance];
    }
    return self;
}

- (void)configureAppearance {
    self.clipsToBounds = YES;
}

- (void)dealloc {
    [self invalidate];
}

#pragma mark - Public

- (void)makeRequest:(BDMRequest *)request {
    [self populateWithRequest:(BDMBannerRequest *)request];
}

- (void)populateWithRequest:(BDMBannerRequest *)request {
    NSAssert(BDMBannerRequest.stk_isValid(request), @"BDMBannerView request should be kind of class BDMBannerRequest");
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
            [self.delegate bannerView:self failedWithError:error];
            break; }
        case BDMRequestStateAuction: {
            [self.currentRequest registerDelegate:self];
            break; }
        case BDMRequestStateExpired: {
            NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Auction response was expired"];
            [self.delegate bannerView:self failedWithError:error];
            break; }
    }
}

- (BDMAuctionInfo *)latestAuctionInfo {
    return self.currentRequest.info;
}

- (BOOL)isLoaded {
    return self.displayAd.hasLoadedCreative;
}

- (BOOL)canShow {
    return self.displayAd.availableToPresent;
}

#pragma mark - Private

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if (!self.displayAd.hasLoadedCreative) {
        return;
    }
    
    [self.middleware startEvent:BDMEventImpression];
    [self.middleware startEvent:BDMEventClosed];
    [self.middleware startEvent:BDMEventClick];
    [self.middleware startEvent:BDMEventViewable];
    
    [self.currentRequest cancelExpirationTimer];
    self.isCreativeOnScreen = YES;
    self.displayAd.delegate = self;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.displayAd presentAd:rootViewController container:self];
    }];
}

- (void)prepareDisplayAd {
    NSError * error;
    self.displayAd = [BDMFactory.sharedFactory displayAdWithRequest:self.currentRequest error:&error];
    if (error) {
        [self.delegate bannerView:self failedWithError:error];
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
}

- (BOOL)hasLoadedCreative {
    return self.displayAd != nil;
}

- (BOOL)isOnScreen {
    return self.superview != nil;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (self.isLoaded && !self.isCreativeOnScreen) {
        [self presentFromRootViewController:self.rootViewController];
    }
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    [self prepareDisplayAd];
}

- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    [self.delegate bannerView:self failedWithError:error];
}

- (void)requestDidExpire:(BDMRequest *)request {
    [self.middleware rejectEvent:BDMEventImpression code:BDMErrorCodeWasExpired];
    if ([self.delegate respondsToSelector:@selector(bannerViewDidExpire:)]) {
        [self.delegate bannerViewDidExpire:self];
    }
}

#pragma mark - BDMDisplayAdDelegate

- (void)displayAdReady:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventCreativeLoading];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    if ([self.delegate respondsToSelector:@selector(bannerView:readyToPresentAd:)]) {
        [self.delegate bannerView:self readyToPresentAd:self.latestAuctionInfo];
    }
#pragma clang diagnostic pop
    [self.delegate bannerViewReadyToPresent:self];
    self.isCreativeOnScreen = NO;
    if (self.isOnScreen) {
        [self presentFromRootViewController:self.rootViewController];
    }
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedWithError:(NSError *)error {
    [self.middleware rejectEvent:BDMEventCreativeLoading code:error.code];
    [self.delegate bannerView:self failedWithError:error];
}

- (void)displayAdLogStartView:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventImpression];
}

- (void)displayAdLogImpression:(id<BDMDisplayAd>)displayAd {
    [BDMSdk.sharedSdk.contextualController registerImpressionForPlacement:self.currentRequest.placementType];
    [self.middleware fulfillEvent:BDMEventViewable];
}

- (void)displayAdLogFinishView:(id<BDMDisplayAd>)displayAd {
    [self.middleware fulfillEvent:BDMEventClosed];
}

- (void)displayAdLogUserInteraction:(id<BDMDisplayAd>)displayAd {
    [BDMSdk.sharedSdk.contextualController registerClickForPlacement:self.currentRequest.placementType];
    [self.middleware fulfillEvent:BDMEventClick];
    [self.delegate bannerViewRecieveUserInteraction:self];
}

- (void)displayAd:(id<BDMDisplayAd>)displayAd failedToPresent:(NSError *)error {
    [self.middleware rejectEvent:BDMEventImpression code:error.code];
    [self.delegate bannerView:self failedWithError:error];
}

- (void)displayAdWillLeaveApplication:(id<BDMDisplayAd>)displayAd {
    if ([self.delegate respondsToSelector:@selector(bannerViewWillLeaveApplication:)]) {
        [self.delegate bannerViewWillLeaveApplication:self];
    }
}

- (void)displayAdWillPresentScreen:(id<BDMDisplayAd>)displayAd {
    if ([self.delegate respondsToSelector:@selector(bannerViewWillPresentScreen:)]) {
        [self.delegate bannerViewWillPresentScreen:self];
    }
}

- (void)displayAdDidDismissScreen:(id<BDMDisplayAd>)displayAd {
    if ([self.delegate respondsToSelector:@selector(bannerViewDidDismissScreen:)]) {
        [self.delegate bannerViewDidDismissScreen:self];
    }
}

@end
