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

@interface BDMNativeAdViewDisplayAd () <BDMViewabilityMetricProviderDelegate, BDMNativeAdAdapterDelegate>

@property (nonatomic, strong) BDMViewabilityMetricProvider * metricProvider;
@property (nonatomic, strong) id <BDMNativeAdServiceAdapter> serviceAdapter;
@property (nonatomic, strong) id <BDMNativeAdAdapter> nativeAdAdapter;

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

- (void)presentOn:(UIView *)view
   clickableViews:(NSArray<UIView *> *)clickableViews
      adRendering:(id<BDMNativeAdRendering>)adRendering
       controller:(UIViewController *)controller
            error:(NSError *__autoreleasing  _Nullable *)error
{
    BDMLog(@"Trying to present adapter: %@ with viewability configuration: %@", self.nativeAdAdapter, self.viewabilityConfig);
    NSError *internalError = nil;
    if (![self validateRenderingAd:adRendering error:error]) {
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
    
    self.containerView = view;
    @try {
        clickableViews = clickableViews.count ? clickableViews : @[adRendering.callToActionLabel, adRendering.titleLabel];
        
        self.nativeAdAdapter.delegate = self;
        [self.nativeAdAdapter presentOn:view
                         clickableViews:clickableViews
                            adRendering:adRendering
                             controller:controller];
        // Viewability
        [self.metricProvider startViewabilityMonitoringForView:view
                                                 configuration:self.viewabilityConfig
                                                      delegate:self];
    }
    @catch (NSException * exc) {
        BDMLog(@"Adapter: %@ raised exception: %@", self.nativeAdAdapter, exc);
        STK_SET_AUTORELASE_VAR(error, exc.bdm_wrappedError);
        [self.delegate displayAd:self failedToPresent:exc.bdm_wrappedError];
    }
}

- (id<BDMNativeAdAssets>)assets {
    return self.nativeAdAdapter;
}

- (void)invalidate {
    [self.nativeAdAdapter invalidate];
    [self.metricProvider finishViewabilityMonitoringForView:self.containerView];
    [super invalidate];
}

- (void)unregisterViews {
    [self.metricProvider finishViewabilityMonitoringForView:self.containerView];
    [self.nativeAdAdapter unregisterView];
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
    BOOL containsIcon = [renderingAd respondsToSelector:@selector(iconView)] && UIImageView.stk_isValid(renderingAd.iconView);
    BOOL containsMedia = [renderingAd respondsToSelector:@selector(mediaContainerView)] && UIView.stk_isValid(renderingAd.mediaContainerView);
    BOOL isValidField = UILabel.stk_isValid(renderingAd.titleLabel) && UILabel.stk_isValid(renderingAd.callToActionLabel) && UILabel.stk_isValid(renderingAd.descriptionLabel);
    BOOL isValidMedia = containsIcon || containsMedia;
    
    if (!(isValidField && isValidMedia)) {
        STK_SET_AUTORELASE_VAR(error, [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:@"Rendering ad have not valid format"]);
    }
    return isValidField && isValidMedia;
}

#pragma mark - BDMViewabilityMetricProviderDelegate

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectFinishView:(UIView *)view {
    BDMLog(@"Adapter: %@ detected viewability finish event", self.nativeAdAdapter);
    [self.delegate displayAdLogFinishView:self];
    if ([self.nativeAdAdapter respondsToSelector:@selector(nativeAdDidTrackFinish)]) {
        [self.nativeAdAdapter nativeAdDidTrackFinish];
    }
}

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectImpression:(UIView *)view {
    BDMLog(@"Adapter: %@ detected viewability impression event", self.nativeAdAdapter);
    [self.delegate displayAdLogImpression:self];
    if ([self.nativeAdAdapter respondsToSelector:@selector(nativeAdDidTrackViewability)]) {
        [self.nativeAdAdapter nativeAdDidTrackViewability];
    }
}

- (void)viewabilityMetricProvider:(BDMViewabilityMetricProvider *)provider detectStartView:(UIView *)view {
    BDMLog(@"Adapter: %@ detected viewability start event", self.nativeAdAdapter);
    [self.delegate displayAdLogStartView:self];
    if ([self.nativeAdAdapter respondsToSelector:@selector(nativeAdDidTrackImpression)]) {
        [self.nativeAdAdapter nativeAdDidTrackImpression];
    }
}

#pragma mark - BDMNativeAdAdapterDelegate

- (void)nativeAdAdapterTrackUserInteraction:(id<BDMNativeAdAdapter>)adapter {
     BDMLog(@"Adapter: %@ registered user interaction", adapter);
    [self.delegate displayAdLogUserInteraction:self];
}

#pragma mark - Override

- (void)service:(id<BDMNativeAdServiceAdapter>)service didLoadNativeAds:(NSArray <id<BDMNativeAdAdapter>> *)nativeAds {
    self.nativeAdAdapter = nativeAds.firstObject;
    //TODO: Append validation (now nothing validate)
    [super service:service didLoadNativeAds:nativeAds];
}

@end
