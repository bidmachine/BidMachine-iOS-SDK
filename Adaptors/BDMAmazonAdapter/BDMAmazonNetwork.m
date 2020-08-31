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
#import "BDMAmazonAdLoader.h"

@interface BDMAmazonNetwork()

@property (nonatomic, assign) BOOL hasBeenInitialized;
@property (nonatomic, strong) NSHashTable <BDMAmazonAdLoader *> *loaders;

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

- (NSHashTable<BDMAmazonAdLoader *> *)loaders {
    if (!_loaders) {
        _loaders = [[NSHashTable alloc] init];
    }
    return _loaders;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError * _Nullable))completion {
    [self syncMetadata];
    if (self.hasBeenInitialized) {
        STK_RUN_BLOCK(completion, NO, nil);
        return;
    }
    
    NSString *appKey = [BDMAmazonValueTransformer.new transformedValue:parameters[@"app_key"]];
    [self.amazonUtils configureSlotsDict:parameters];
    if (!appKey) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Amazon adapter was not receive valid initialization data"];
        STK_RUN_BLOCK(completion, NO, error);
        return;
    }
    
    self.hasBeenInitialized = YES;
    [DTBAds.sharedInstance setAppKey:appKey];
    STK_RUN_BLOCK(completion, YES, nil);
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void (^)(NSDictionary<NSString *,id> *, NSError *))completion {
    BDMAmazonAdLoader *loader = [[BDMAmazonAdLoader alloc] initWithServerParameters:parameters];
    [self.loaders addObject:loader];
    __weak typeof(self) weakSelf = self;
    [loader prepareWithCompletion:^(BDMAmazonAdLoader *loader,
                                    NSDictionary<NSString *,id> *biddingParameters,
                                    NSError *error) {
        [weakSelf.loaders removeObject:loader];
        STK_RUN_BLOCK(completion, parameters, error);
    }];
}

- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk {
    return [BDMAmazonBannerAdapter new];
}

- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk {
    return [BDMAmazonInterstitialAdapter new];
}

#pragma mark - Private

- (void)syncMetadata {
    [DTBAds.sharedInstance setLogLevel:BDMSdkLoggingEnabled ? DTBLogLevelAll : DTBLogLevelOff];
    [DTBAds.sharedInstance setUseGeoLocation:STKLocation.locationTrackingEnabled];

    DTBAds.sharedInstance.mraidPolicy = CUSTOM_MRAID;
    DTBAds.sharedInstance.mraidCustomVersions = @[@"1.0", @"2.0", @"3.0"];
}

@end
