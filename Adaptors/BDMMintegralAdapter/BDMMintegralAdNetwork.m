//
//  BDMMintegralAdNetwork.m
//  BDMMintegralAdNetwork
//
//  Created by Yaroslav Skachkov on 8/16/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import StackFoundation;

#import "BDMMintegralAdNetwork.h"
#import "BDMMintegralValueTransformer.h"
#import "BDMMintegralFullscreenAdapter.h"
#import "BDMMintegralNativeAdServiceAdapter.h"

#import <MTGSDK/MTGSDK.h>
#import <MTGSDKBidding/MTGBiddingSDK.h>

@interface BDMMintegralAdNetwork()

@property (nonatomic, copy) NSString *appId;

@end

@implementation BDMMintegralAdNetwork

- (NSString *)name {
    return @"mintegral";
}

- (NSString *)sdkVersion {
    return MTGSDKVersion;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    [self syncMetadata];
    if (self.appId) {
        STK_RUN_BLOCK(completion, NO, nil);
        return;
    }
    
    self.appId = [BDMMintegralValueTransformer.new transformedValue:parameters[@"app_id"]];
    NSString *apiKey = [BDMMintegralValueTransformer.new transformedValue:parameters[@"api_key"]];
    if (!self.appId || !apiKey) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Mintegral adapter was not receive valid initialization data"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    [MTGSDK.sharedInstance setAppID:self.appId ApiKey:apiKey];
    STK_RUN_BLOCK(completion, YES, nil);
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completion {
    BDMMintegralValueTransformer *transformer = [BDMMintegralValueTransformer new];
    NSString *buyeruid = [MTGBiddingSDK buyerUID];
    NSString *unitId = [transformer transformedValue:parameters[@"unit_id"]];
    NSString *placementId = [transformer transformedValue:parameters[@"placement_id"]];
    if (!self.appId || !buyeruid || !unitId) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Mintegral adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    
    NSMutableDictionary *bidding = [NSMutableDictionary dictionaryWithCapacity:4];
    bidding[@"app_id"] = self.appId;
    bidding[@"buyeruid"] = buyeruid;
    bidding[@"unit_id"] = unitId;
    bidding[@"placement_id"] = placementId;
    
    STK_RUN_BLOCK(completion, bidding, nil);
}

- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMintegralFullscreenAdapter new];
}

- (id<BDMNativeAdServiceAdapter>)nativeAdAdapterForSdk:(BDMSdk *)sdk {
    return [BDMMintegralNativeAdServiceAdapter new];
}

#pragma mark - Private

- (void)syncMetadata {
    [[MTGSDK sharedInstance] setConsentStatus:BDMSdk.sharedSdk.restrictions.hasConsent];
}

@end
