//
//  BDMMyTargetNativeAdServiceAdapter.m
//  BDMMyTargetAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMyTargetNativeAdServiceAdapter.h"
#import "BDMMyTargetNativeAdDisplayAdapter.h"
#import "BDMMyTargetSlotTransformer.h"
#import "BDMMyTargetCustomParams.h"

@import StackUIKit;
@import MyTargetSDK;

@interface BDMMyTargetNativeAdServiceAdapter ()<MTRGNativeAdDelegate>

@property (nonatomic, strong) MTRGNativeAd *nativeAd;

@end

@implementation BDMMyTargetNativeAdServiceAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *slot = [BDMMyTargetSlotTransformer.new transformedValue:contentInfo[@"slot_id"]];
    NSString *bid = [BDMMyTargetSlotTransformer.new transformedValue:contentInfo[@"bid_id"]];
    
    NSUInteger slotId = [slot integerValue];
    if (slotId == 0 || bid == nil) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent description:@"MyTarget slot id or bid id wasn't found"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.nativeAd = [[MTRGNativeAd alloc] initWithSlotId:slotId];
    self.nativeAd.delegate = self;
    self.nativeAd.autoLoadImages = false;
    
    [BDMMyTargetCustomParams populate:self.nativeAd.customParams];
    [self.nativeAd loadFromBid:bid];
}

#pragma mark - MTRGNativeAdDelegate

- (void)onLoadWithNativePromoBanner:(nonnull MTRGNativePromoBanner *)promoBanner nativeAd:(nonnull MTRGNativeAd *)nativeAd {
    BDMMyTargetNativeAdDisplayAdapter *nativeAdAdapter = [BDMMyTargetNativeAdDisplayAdapter displayAdapterForAd:nativeAd];
    [self.loadingDelegate service:self didLoadNativeAds:@[nativeAdAdapter]];
}

- (void)onNoAdWithReason:(nonnull NSString *)reason nativeAd:(nonnull MTRGNativeAd *)nativeAd {
    NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent description:reason];
    [self.loadingDelegate adapter:self failedToPrepareContentWithError: error];
}

@end
