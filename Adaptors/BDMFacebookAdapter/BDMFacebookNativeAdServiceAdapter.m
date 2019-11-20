//
//  BDMFacebookNativeAdServiceAdapter.m
//  BDMFacebookAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMFacebookNativeAdServiceAdapter.h"
#import "BDMFacebookStringValueTransformer.h"
#import "BDMFacebookNativeAdDisplayAdapter.h"

@import FBAudienceNetwork;
@import StackFoundation;

@interface BDMFacebookNativeAdServiceAdapter()<FBNativeAdDelegate>

@property (nonatomic, strong) FBNativeAd *nativeAd;

@end

@implementation BDMFacebookNativeAdServiceAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    BDMFacebookStringValueTransformer *transformer = [BDMFacebookStringValueTransformer new];
    NSString *placement = [transformer transformedValue:contentInfo[@"facebook_key"]];
    NSString *payload = [transformer transformedValue:contentInfo[@"bid_payload"]];
    if (!placement || !payload) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"FBAudienceNetwork wasn'r recived valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.nativeAd = [[FBNativeAd alloc] initWithPlacementID:placement];
    self.nativeAd.delegate = self;
    [self.nativeAd loadAdWithBidPayload:payload mediaCachePolicy:FBNativeAdsCachePolicyNone];
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    BDMFacebookNativeAdDisplayAdapter *nativeAdAdapter = [BDMFacebookNativeAdDisplayAdapter displayAdapterForAd:nativeAd];
    [self.loadingDelegate service:self didLoadNativeAds:@[nativeAdAdapter]];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
}

@end
