//
//  BDMBaseDisplayAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 14/01/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMBaseDisplayAd.h"
#import "BDMDefines.h"
#import "NSError+BDMSdk.h"
#import "BDMSdk+Project.h"


@interface BDMBaseDisplayAd ()

@property (nonatomic, strong, readwrite) BDMResponse *response;
@property (nonatomic, assign, readwrite) BOOL hasLoadedCreative;

@end

@implementation BDMBaseDisplayAd

- (instancetype)initWithResponse:(BDMResponse *)response {
    if (self = [super init]) {
        self.response = response;
    }
    return self;
}

+ (instancetype)displayAdWithResponse:(id<BDMResponse>)response placementType:(BDMInternalPlacementType)placementType {
    BDMLog(@"BDMBaseDisplayAd can't be initialized by +displayAdWithAdapter:response:!");
    return nil;
}

- (BOOL)availableToPresent {
    return self.hasLoadedCreative && BDMSdk.sharedSdk.isDeviceReachable;
}

- (void)invalidate {
    self.hasLoadedCreative = NO;
}

- (void)presentAd:(UIViewController *)controller container:(UIView *)container {
    BDMLog(@"BDMBaseDisplayAd can't present any ad!");
}

- (void)prepare {
    BDMLog(@"BDMBaseDisplayAd can't prepare any ad without adapter!");
}

- (NSString *)displayManager {
    return self.response.creative.displaymanager;
}

- (NSString *)responseID {
    return self.response.identifier;
}

- (BDMViewabilityMetricConfiguration *)viewabilityConfig {
    return self.response.creative.viewabilityConfig;
}

- (void)prepareAdapter:(id<BDMAdapter>)adapter {
    if (!adapter) {
        BDMLog(@"Adapter for response with id: %@ wasn't found!", self.response.identifier ?: @"unknown id");
        NSError * error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"Adapter wasn't found"];
        [self.delegate displayAd:self failedWithError:error];
        return;
    }
    
    adapter.loadingDelegate = self;
    @try {
        [adapter prepareContent:self.response.creative.renderingInfo];
    }
    @catch (NSException *exc) {
        BDMLog(@"Adapter: %@ raised exception: %@", adapter, exc);
        [self.delegate displayAd:self failedWithError:exc.bdm_wrappedError];
    }
}

#pragma mark - BDMAdapterLoadingDelegate

- (void)adapterPreparedContent:(id<BDMAdapter>)adapter {
    self.hasLoadedCreative = YES;
    BDMLog(@"Adapter prepared ad content: %@", adapter);
    [self.delegate displayAdReady:self];
}

- (void)adapter:(id<BDMAdapter>)adapter failedToPrepareContentWithError:(NSError *)error {
    self.hasLoadedCreative = NO;
    BDMLog(@"Adapter failed to prepare ad content: %@", error);
    [self.delegate displayAd:self failedWithError:error];
}

#pragma mark - BDMNativeAdServiceAdapterLoadingDelegate

- (void)service:(id<BDMNativeAdServiceAdapter>)service didLoadNativeAds:(NSArray <id<BDMNativeAdAdapter>> *)nativeAds {
    self.hasLoadedCreative = YES;
    BDMLog(@"Adapter prepared ad content: %@", service);
    [self.delegate displayAdReady:self];
}

@end
