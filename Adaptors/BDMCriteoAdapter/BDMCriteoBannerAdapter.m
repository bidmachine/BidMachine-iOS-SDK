//
//  BDMCriteoBannerAdapter.m
//
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import StackUIKit;
@import StackFoundation;

#import "BDMCriteoBannerAdapter.h"


@interface BDMCriteoBannerAdapter () <CRBannerViewDelegate>

@property (nonatomic, strong) CRBannerView *bannerView;
@property (nonatomic,   weak) id<BDMCriteoAdNetworkProvider> provider;

@end

@implementation BDMCriteoBannerAdapter

- (instancetype)initWithProvider:(id<BDMCriteoAdNetworkProvider>)provider {
    if (self = [super init]) {
        self.provider = provider;
    }
    return self;
}

- (UIView *)adView {
    return self.bannerView;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *adUnitId = ANY(contentInfo).from(BDMCriteoAdUnitIDKey).string;
    if (!adUnitId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Criteo wasn't recived valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    CRBannerAdUnit *adUnit = [[CRBannerAdUnit alloc] initWithAdUnitId:adUnitId size:[self.displayDelegate sizeForAdapter:self]];
    CRBid *bid = [self.provider bidForAdUnitId:adUnitId];
    
    if (!bid) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Criteo bid nil"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.bannerView = [[CRBannerView new] initWithAdUnit:adUnit];
    self.bannerView.delegate = self;
    [self.bannerView loadAdWithBid:bid];
}

- (void)presentInContainer:(UIView *)container {
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.bannerView stk_edgesEqual:container];
}

#pragma mark - CRBannerViewDelegate

- (void)banner:(CRBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)bannerDidReceiveAd:(CRBannerView *)bannerView {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)bannerWillLeaveApplication:(CRBannerView *)bannerView {
    [self.displayDelegate adapterWillLeaveApplication:self];
}

- (void)bannerWasClicked:(CRBannerView *)bannerView {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

@end
