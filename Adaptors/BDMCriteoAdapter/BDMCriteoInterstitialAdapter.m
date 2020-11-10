//
//  BDMCriteoInterstitialAdapter.m
//
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import StackFoundation;

#import "BDMCriteoInterstitialAdapter.h"


@interface BDMCriteoInterstitialAdapter ()<CRInterstitialDelegate>

@property (nonatomic, strong) CRInterstitial *interstitial;
@property (nonatomic,   weak) id<BDMCriteoAdNetworkProvider> provider;


@end

@implementation BDMCriteoInterstitialAdapter

- (instancetype)initWithProvider:(id<BDMCriteoAdNetworkProvider>)provider {
    if (self = [super init]) {
        self.provider = provider;
    }
    return self;
}

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *adUnitId = ANY(contentInfo).from(BDMCriteoAdUnitIDKey).string;
    if (!adUnitId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Criteo wasn't recived valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    CRInterstitialAdUnit *adUnit = [[CRInterstitialAdUnit alloc] initWithAdUnitId:adUnitId];
    CRBid *bid = [self.provider bidForAdUnitId:adUnitId];
    
    if (!bid) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Criteo bid token nil"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.interstitial = [[CRInterstitial alloc] initWithAdUnit:adUnit];
    self.interstitial.delegate = self;
    [self.interstitial loadAdWithBid:bid];
}

- (void)present {
    if ([self.interstitial isAdLoaded]) {
        UIViewController *controller = [self.displayDelegate rootViewControllerForAdapter:self];
        [self.interstitial presentFromRootViewController:controller];
    } else {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"Criteo fullscreen adapter not ready"];
        [self.displayDelegate adapter:self failedToPresentAdWithError:error];
    }
}

#pragma mark - CRInterstitialDelegate

- (void)interstitialDidReceiveAd:(CRInterstitial *)interstitial {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)interstitial:(CRInterstitial *)interstitial didFailToReceiveAdWithError:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)interstitialWillAppear:(CRInterstitial *)interstitial {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)interstitialDidDisappear:(CRInterstitial *)interstitial {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)interstitialWasClicked:(CRInterstitial *)interstitial {
    [self.displayDelegate adapterRegisterUserInteraction:self];
}

@end
