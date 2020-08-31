//
//  BDMMyTargetAdNetwork.m
//  BDMMyTargetAdapter
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import <MyTargetSDK/MyTargetSDK.h>
#import <StackFoundation/StackFoundation.h>

#import "BDMMyTargetAdNetwork.h"
#import "BDMMyTargetSlotTransformer.h"
#import "BDMMyTargetFullscreenAdapter.h"
#import "BDMMyTargetBannerAdapter.h"
#import "BDMMyTargetNativeAdServiceAdapter.h"


@implementation BDMMyTargetAdNetwork

- (NSString *)name {
    return @"my_target";
}

- (NSString *)sdkVersion {
    return MTRGVersion.currentVersion;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError *))completion {
    [self syncMetadata];
    STK_RUN_BLOCK(completion, NO, nil);
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void (^)(NSDictionary<NSString *,id> * clientParams,
                                                 NSError *error))completion {
    [self syncMetadata];
    NSString *slotId = [BDMMyTargetSlotTransformer.new transformedValue:parameters[@"slot_id"]];
    NSDictionary *clientParams;
    NSError *error;
    if (slotId.length) {
        clientParams = [NSDictionary dictionaryWithObject:slotId forKey:@"slot_id"];
    } else {
        error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                               description:@"MyTarget ad unit not contains valid slot id"];
    }
    STK_RUN_BLOCK(completion, clientParams, error);
}

- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMyTargetFullscreenAdapter new];
}

- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMyTargetFullscreenAdapter new];
}

- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMyTargetBannerAdapter new];
}

- (id<BDMNativeAdServiceAdapter>)nativeAdAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMyTargetNativeAdServiceAdapter new];
}

#pragma mark - Private

- (void)syncMetadata {
    MTRGPrivacy.userAgeRestricted = BDMSdk.sharedSdk.restrictions.coppa;
    
    if (BDMSdk.sharedSdk.restrictions.subjectToGDPR) {
        MTRGPrivacy.userConsent = BDMSdk.sharedSdk.restrictions.hasConsent;
    }
}

@end
