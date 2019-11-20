//
//  BDMMintegralNativeAdServiceAdapter.m
//  BDMMintegralAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMintegralNativeAdServiceAdapter.h"
#import "BDMMintegralValueTransformer.h"
#import "BDMMintegralNativeAdDisplayAdapter.h"

#import <MTGSDK/MTGSDK.h>
#import <MTGSDK/MTGBidNativeAdManager.h>
#import <StackFoundation/StackFoundation.h>

@interface BDMMintegralNativeAdServiceAdapter ()<MTGBidNativeAdManagerDelegate>

@property (nonatomic, strong) MTGBidNativeAdManager *nativeAdManager;

@end

@implementation BDMMintegralNativeAdServiceAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    BDMMintegralValueTransformer *transformer = [BDMMintegralValueTransformer new];
    NSString *bidToken = [transformer transformedValue:contentInfo[@"bid_token"]];
    NSString *unitId = [transformer transformedValue:contentInfo[@"unit_id"]];
    if (!bidToken || !unitId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeBadContent
                                        description:@"Mintegral adapter was not recive valid bidding data"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
        return;
    }
    
    self.nativeAdManager = [[MTGBidNativeAdManager alloc] initWithUnitID:unitId
                                                          autoCacheImage:NO
                                                presentingViewController:nil];
    self.nativeAdManager.delegate = self;
    [self.nativeAdManager loadWithBidToken:bidToken];
}

#pragma mark - MTGBidNativeAdManagerDelegate

- (void)nativeAdsLoaded:(nullable NSArray *)nativeAds bidNativeManager:(nonnull MTGBidNativeAdManager *)bidNativeManager {
    NSArray <MTGCampaign *> *compains = ANY(nativeAds).filter(^BOOL (id obj){
        return MTGCampaign.stk_isValid(obj);
    }).array;
    if (compains.count) {
        BDMMintegralNativeAdDisplayAdapter *nativeAdAdapter = [BDMMintegralNativeAdDisplayAdapter displayAdapterForAd:compains.firstObject
                                                                                                              manager:self.nativeAdManager];
        [self.loadingDelegate service:self didLoadNativeAds:@[nativeAdAdapter]];
    } else {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeNoContent
                                        description:@"Mintegral adapter not contains native ad"];
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
    }
}

- (void)nativeAdsFailedToLoadWithError:(nonnull NSError *)error bidNativeManager:(nonnull MTGBidNativeAdManager *)bidNativeManager {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
}

@end
