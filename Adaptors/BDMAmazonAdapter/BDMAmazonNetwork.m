//
//  BDMAmazonNetwork.m
//  BDMAmazonNetwork
//
//  Created by Yaroslav Skachkov on 9/10/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import DTBiOSSDK;
@import StackFoundation;

#import "BDMAmazonValueTransformer.h"
#import "BDMAmazonNetwork.h"
#import "BDMAmazonBannerAdapter.h"
#import "BDMAmazonInterstitialAdapter.h"
#import "BDMAmazonUtils.h"

@interface BDMAmazonNetwork() <DTBAdCallback>

@property (nonatomic, copy) void (^completion)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable);

@end

@implementation BDMAmazonNetwork

- (NSString *)name {
    return @"amazon";
}

- (NSString *)sdkVersion {
    return [DTBAds version];
}

- (BDMAmazonUtils *)amazonUtils {
    return [BDMAmazonUtils sharedInstance];
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    NSString *appKey = [BDMAmazonValueTransformer.new transformedValue:parameters[@"app_key"]];
    [[self amazonUtils] configureSlotsDict:parameters];
    if (!appKey) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Amazon adapter was not receive valid initialization data"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    [[DTBAds sharedInstance] setAppKey: appKey];
    [self syncMetadata];
    STK_RUN_BLOCK(completion, YES, nil);
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                            completion:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completion {
    NSString *slotUUID = [BDMAmazonValueTransformer.new transformedValue:parameters[@"slot_uuid"]];
    if (!slotUUID) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Amazon adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    DTBAdLoader *amazonAdLoader = [DTBAdLoader new];
    NSArray<DTBAdSize *> *adSizes = [[self amazonUtils] configureAdSizesWith:slotUUID];
    [amazonAdLoader setAdSizes:adSizes];
    [amazonAdLoader loadAd:self];
    [self saveCompletion:completion];
}

- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk {
    return [BDMAmazonBannerAdapter new];
}

- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk {
    return [BDMAmazonInterstitialAdapter new];
}

#pragma mark - Private

- (void)syncMetadata {
    [[DTBAds sharedInstance] setLogLevel:BDMSdkLoggingEnabled ? DTBLogLevelAll : DTBLogLevelOff];
    [DTBAds sharedInstance].mraidPolicy = CUSTOM_MRAID;
    [DTBAds sharedInstance].mraidCustomVersions = @[@"1.0", @"2.0", @"3.0"];
    
    [[DTBAds sharedInstance] setUseGeoLocation:STKLocation.locationTrackingEnabled];
    
    [[DTBAds sharedInstance] setTestMode:YES];
}

- (void)saveCompletion:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completion {
    self.completion = completion;
}

#pragma mark - DTBAdCallback

- (void)onSuccess:(DTBAdResponse *)adResponse {
    NSMutableDictionary *bidding = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithDictionary:adResponse.customTargeting];
    NSString *slot = response[@"amznslots"];
    bidding[@"amznslots"] = slot;
    if (response[@"amzn_vid"]) {
        bidding[@"amzn_vid"] = response[@"amzn_vid"];
    }
    bidding[@"amzn_h"] = response[@"amzn_h"];
    bidding[@"amzn_b"] = response[@"amzn_b"];
    bidding[@"amznrdr"] = [response[@"amznrdr"] firstObject];
    bidding[@"amznp"] = [response[@"amznp"] firstObject];
    bidding[@"dc"] = [response[@"dc"] firstObject];
    if (self.completion) {
        STK_RUN_BLOCK(self.completion, bidding, nil);
    }
}

- (void)onFailure:(DTBAdError)error { }

@end
