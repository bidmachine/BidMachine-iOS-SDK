//
//  BDMBannerViewDisplayAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 29/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMBannerViewDisplayAd.h"
#import "NSError+BDMSdk.h"
#import "BDMViewabilityMetricProvider.h"
#import "BDMSdk+Project.h"


@interface BDMBannerViewDisplayAd () <BDMBannerAdapterDisplayDelegate, BDMViewabilityMetricProviderDelegate>

@property (nonatomic, strong) id <BDMBannerAdapter> adapter;
@property (nonatomic, strong) BDMViewabilityMetricProvider *metricProvider;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, weak) UIView *container;

@end

@implementation BDMBannerViewDisplayAd

#pragma mark - BDMDisplayAd

+ (instancetype)displayAdWithResponse:(id<BDMResponse>)response placementType:(BDMInternalPlacementType)placementType {
    if (placementType != BDMInternalPlacementTypeBanner) {
        BDMLog(@"Trying to initialise BDMBannerViewDisplayAd with placement of unsupported type");
        return nil;
    }
    
    id <BDMBannerAdapter> adapter;
    BDMBannerViewDisplayAd * displayAd = [[BDMBannerViewDisplayAd alloc] initWithResponse:response];
    adapter = [BDMSdk.sharedSdk bannerAdapterForNetwork:displayAd.displayManager];

    displayAd.adapter = adapter;
    adapter.displayDelegate = displayAd;
    
    return displayAd;
}

- (void)presentAd:(UIViewController *)controller container:(UIView *)container {
    self.rootViewController = controller;
    self.container = container;
    BDMLog(@"Trying to present adapter: %@ with viewability configuration: %@", self.adapter, self.viewabilityConfig);
    [self.metricProvider startViewabilityMonitoringForView:container
                                             configuration:self.viewabilityConfig
                                                  delegate:self];
    @try {
        [self.adapter presentInContainer:container];
    }
    @catch (NSException * exc) {
        BDMLog(@"Adapter: %@ raised exception: %@", self.adapter, exc);
        [self.delegate displayAd:self failedToPresent:exc.bdm_wrappedError];
    }
}

- (void)prepare {
    [self prepareAdapter:self.adapter];
}

- (void)invalidate {
    BDMLog(@"Invalidating ad: %@", self);
    [self.metricProvider finishViewabilityMonitoringForView:self.adView];
    self.adapter.displayDelegate = nil;
    [super invalidate];
}

- (UIView *)adView {
    return self.container;
}

- (BDMViewabilityMetricProvider *)metricProvider {
    if (!_metricProvider) {
        _metricProvider = [BDMViewabilityMetricProvider new];
        _metricProvider.delegate = self;
    }
    return _metricProvider;
}

#pragma mark - BDMBannerAdapterDisplayDelegate

- (void)adapter:(id<BDMAdapter>)adapter failedToPresentAdWithError:(NSError *)error {
    BDMLog(@"Adapter: %@ failed to present with error: %@", adapter, error);
    [self.delegate displayAd:self failedToPresent:error];
}

- (void)adapterRegisterUserInteraction:(id<BDMBannerAdapter>)adapter {
    BDMLog(@"Adapter: %@ registered user interaction", adapter);
    [self.delegate displayAdLogUserInteraction:self];
}

- (UIViewController *)rootViewControllerForAdapter:(id<BDMBannerAdapter>)adapter {
    return self.rootViewController;
}

- (CGSize)sizeForAdapter:(id<BDMBannerAdapter>)adapter {
    return CGSizeFromBDMSize(self.adSize);
}

- (void)adapterWillPresentScreen:(id<BDMBannerAdapter>)adapter {
    BDMLog(@"Adapter: %@ will present screen screen", adapter);
    if ([self.delegate respondsToSelector:@selector(displayAdWillPresentScreen:)]) {
        [self.delegate displayAdWillPresentScreen:self];
    }
}

- (void)adapterDidDismissScreen:(id<BDMBannerAdapter>)adapter {
    BDMLog(@"Adapter: %@ dismissed screen", adapter);
    if ([self.delegate respondsToSelector:@selector(displayAdDidDismissScreen:)]) {
        [self.delegate displayAdDidDismissScreen:self];
    }
}

- (void)adapterWillLeaveApplication:(id<BDMBannerAdapter>)adapter {
    BDMLog(@"Adapter: %@ left application", adapter);
    if ([self.delegate respondsToSelector:@selector(displayAdWillLeaveApplication:)]) {
        [self.delegate displayAdWillLeaveApplication:self];
    }
}

#pragma mark - BDMViewabilityMetricProviderDelegate

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectFinishView:(UIView *)view {
    BDMLog(@"Adapter: %@ detected viewability finish event", self.adapter);
    [self.delegate displayAdLogFinishView:self];
}

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectImpression:(UIView *)view {
    BDMLog(@"Adapter: %@ detected viewability impression event", self.adapter);
    [self.delegate displayAdLogImpression:self];
}

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectStartView:(UIView *)view {
    BDMLog(@"Adapter: %@ detected viewability start event", self.adapter);
    [self.delegate displayAdLogStartView:self];
}

@end
