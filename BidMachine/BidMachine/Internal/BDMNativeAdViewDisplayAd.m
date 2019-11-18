//
//  BDMNativeAdViewDisplayAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 31/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMNativeAdViewDisplayAd.h"
#import "BDMViewabilityMetricProvider.h"
#import "NSError+BDMSdk.h"
#import "BDMSdk+Project.h"

#import <StackFoundation/StackFoundation.h>

@interface BDMNativeAdViewDisplayAd () <BDMNativeAdAdapterDataSource, BDMViewabilityMetricProviderDelegate, BDMNativeAdAdapterDelegate, BDMNativeAdAdapterDataSource>

@property (nonatomic, strong) BDMViewabilityMetricProvider * metricProvider;
@property (nonatomic, strong) id <BDMNativeAdServiceAdapter> serviceAdapter;
@property (nonatomic, strong) id <BDMNativeAdAdapter> nativeAdAdapter;

@property (nonatomic, weak) UIViewController * rootViewController;
@property (nonatomic, weak) id <BDMNativeAdRendering> renderingAd;
@property (nonatomic, weak) UIView * containerView;

@end

@implementation BDMNativeAdViewDisplayAd

+ (instancetype)displayAdWithResponse:(id<BDMResponse>)response placementType:(BDMInternalPlacementType)placementType {
    if (placementType != BDMInternalPlacementTypeNative) {
        BDMLog(@"Trying to initialise BDMNativeAdViewDisplayAd with placement of unsupported type");
        return nil;
    }
    
    id <BDMNativeAdServiceAdapter> adapter;
    BDMNativeAdViewDisplayAd * displayAd = [[BDMNativeAdViewDisplayAd alloc] initWithResponse:response];
    adapter = [BDMSdk.sharedSdk nativeAdAdapterForNetwork:displayAd.displayManager];
    displayAd.serviceAdapter = adapter;
    
    return displayAd;
}

- (void)prepare {
    [self prepareAdapter:self.serviceAdapter];
}

- (void)presentOn:(id<BDMNativeAdRendering>)renderingAd controller:(UIViewController *)controller error:(NSError *__autoreleasing  _Nullable *)error {
    BDMLog(@"Trying to present adapter: %@ with viewability configuration: %@", self.nativeAdAdapter, self.viewabilityConfig);
    NSError *internalError = nil;
    if (![self validateRenderingAd:renderingAd error:error]) {
        STK_SET_AUTORELASE_VAR(error, internalError);
        [self.delegate displayAd:self failedToPresent:internalError];
        return;
    }
    
//    if (![BDMSdk.sharedSdk isDeviceReachable]) {
//        internalError = [NSError bdm_errorWithCode:BDMErrorCodeNoConnection description:@"You are not connected to Internet."];
//        STK_SET_AUTORELASE_VAR(error, internalError);
//        [self.delegate displayAd:self failedToPresent:internalError];
//        return;
//    }
    
    self.rootViewController = controller;
    self.containerView = renderingAd.containerView;
    @try {
        [self.nativeAdAdapter renderOn:renderingAd
                              delegate:self
                            dataSource:self];
        // Viewability
        [self.metricProvider startViewabilityMonitoringForView:renderingAd.containerView
                                                 configuration:self.viewabilityConfig
                                                      delegate:self];
    }
    @catch (NSException * exc) {
        BDMLog(@"Adapter: %@ raise exception: %@", self.nativeAdAdapter, exc);
        STK_SET_AUTORELASE_VAR(error, exc.bdm_wrappedError);
        [self.delegate displayAd:self failedToPresent:exc.bdm_wrappedError];
    }
}

- (void)invalidate {
    [self.metricProvider finishViewabilityMonitoringForView:self.containerView];
    [super invalidate];
}

#pragma mark - Private

- (BDMViewabilityMetricProvider *)metricProvider {
    if (!_metricProvider) {
        _metricProvider = [BDMViewabilityMetricProvider new];
        _metricProvider.delegate = self;
    }
    return _metricProvider;
}

- (BOOL)validateRenderingAd:(id<BDMNativeAdRendering>)renderingAd error:(NSError * _Nullable __autoreleasing *)error {
    BOOL containsIcon = [renderingAd respondsToSelector:@selector(iconView)] && renderingAd.iconView != nil;
    BOOL containsMedia = [renderingAd respondsToSelector:@selector(mediaContainerView)] && renderingAd.mediaContainerView != nil;
    BOOL isValid = containsIcon || containsMedia;
    
    if (!isValid) {
        STK_SET_AUTORELASE_VAR(error, [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Rendering ad shuld contains Media or Icon field"]);
    }
    return isValid;
}

#pragma mark - BDMViewabilityMetricProviderDelegate

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectFinishView:(UIView *)view {
    BDMLog(@"Adapter: %@ finish view", self.nativeAdAdapter);
    [self.delegate displayAdLogFinishView:self];
    if ([self.nativeAdAdapter respondsToSelector:@selector(nativeAdDidTrackFinish)]) {
        [self.nativeAdAdapter nativeAdDidTrackFinish];
    }
}

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectImpression:(UIView *)view {
    BDMLog(@"Adapter: %@ impression view", self.nativeAdAdapter);
    [self.delegate displayAdLogImpression:self];
    if ([self.nativeAdAdapter respondsToSelector:@selector(nativeAdDidTrackViewability)]) {
        [self.nativeAdAdapter nativeAdDidTrackViewability];
    }
}

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectStartView:(UIView *)view {
    BDMLog(@"Adapter: %@ start view", self.nativeAdAdapter);
    [self.delegate displayAdLogStartView:self];
    if ([self.nativeAdAdapter respondsToSelector:@selector(nativeAdDidTrackImpression)]) {
        [self.nativeAdAdapter nativeAdDidTrackImpression];
    }
}

#pragma mark - BDMNativeAdAdapterDelegate

- (void)trackInteraction {
     BDMLog(@"Adapter: %@ register user interaction", self.nativeAdAdapter);
    [self.delegate displayAdLogUserInteraction:self];
}

#pragma mark - BDMNativeAdAdapterDataSource;

- (nonnull UIViewController *)rootViewController {
    return self.rootViewController;
}

#pragma mark - Override

- (void)service:(id<BDMNativeAdServiceAdapter>)service didLoadNativeAds:(NSArray <id<BDMNativeAdAdapter>> *)nativeAds {
    self.nativeAdAdapter = nativeAds.firstObject;
    //TODO: Append validation (now nothing validate)
    [super service:service didLoadNativeAds:nativeAds];
}

@end
