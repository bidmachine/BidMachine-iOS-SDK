//
//  BDMCriteoAdNetwork.m
//
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMCriteoAdNetwork.h"
#import "BDMCriteoBannerAdapter.h"
#import "BDMCriteoInterstitialAdapter.h"
#import <StackFoundation/StackFoundation.h>
#import <CriteoPublisherSdk/CriteoPublisherSdk.h>


@interface BDMCriteoAdNetwork ()

@property (nonatomic, assign) BOOL hasBeenInitialized;
@property (nonatomic, strong) NSMapTable *bidTokenStorage;

@end


@implementation BDMCriteoAdNetwork

- (NSString *)name {
    return @"criteo";
}

- (NSString *)sdkVersion {
    return @"3.4.1";
}

- (NSMapTable *)bidTokenStorage {
    if (!_bidTokenStorage) {
        _bidTokenStorage = [NSMapTable strongToStrongObjectsMapTable];
    }
    return _bidTokenStorage;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError *))completion {
    if (self.hasBeenInitialized) {
        STK_RUN_BLOCK(completion, NO, nil);
        return;
    }
    
    NSString *publisherId = parameters[@"publisher_id"];
    NSArray *bannerAdUnitsArray = parameters[@"banner_ad_units"];
    NSArray *interstitialAdUnitsArray = parameters[@"interstitial_ad_units"];
    if (!NSString.stk_isValid(publisherId)) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Criteo adapter was not receive valid publisher id"];
        STK_RUN_BLOCK(completion, NO, error);
        return;
    }
    
    NSArray <CRBannerAdUnit *> *bannerAdUnits = ANY(bannerAdUnitsArray).flatMap(^CRBannerAdUnit *(NSString *value){
        return NSString.stk_isValid(value) ? [self bannerAdUnit:value size:CGSizeZero] : nil;
    }).array;
    NSArray <CRInterstitialAdUnit *> *interstitialAdUnits = ANY(interstitialAdUnitsArray).flatMap(^CRInterstitialAdUnit *(NSString *value){
        return NSString.stk_isValid(value) ? [self interstitialAdUnit:value] : nil;
    }).array;
    
    NSArray *adUnits = [NSArray stk_concat:bannerAdUnits, interstitialAdUnits, nil];
    
    self.hasBeenInitialized = YES;
    [Criteo.sharedCriteo registerCriteoPublisherId:publisherId
                                       withAdUnits:adUnits];
    STK_RUN_BLOCK(completion, YES, nil);
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void (^)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable))completion {
    NSString *adUnitId = parameters[@"ad_unit_id"];
    
    if (!NSString.stk_isValid(adUnitId) || ![self isValidOrientation:parameters[@"orientation"]]) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Criteo adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    
    CRAdUnit *adUnit = [self adUnitByFormat:adUnitFormat adUnitId:adUnitId];
    CRBidResponse *bidResponse = [self bidResponseForAdUnit:adUnit];
    if (!bidResponse) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Criteo adapter bid response not ready"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    
    NSMutableDictionary *bidding = [[NSMutableDictionary alloc] initWithCapacity:2];
    bidding[@"price"] = @(bidResponse.price);
    bidding[@"ad_unit_id"] = adUnitId;
    
    [self.bidTokenStorage setObject:bidResponse.bidToken forKey:adUnitId];
    STK_RUN_BLOCK(completion, bidding, nil);
}

- (id<BDMBannerAdapter>)bannerAdapterForSdk:(BDMSdk *)sdk {
    return [[BDMCriteoBannerAdapter alloc] initWithProvider:self];;
}

- (id<BDMFullscreenAdapter>)interstitialAdAdapterForSdk:(BDMSdk *)sdk {
    return [[BDMCriteoInterstitialAdapter alloc] initWithProvider:self];
}

- (CRBidToken *)bidTokenForAdUnitId:(NSString *)adUnitId {
    CRBidToken *bidToken = [self.bidTokenStorage objectForKey:adUnitId];
    [self.bidTokenStorage removeObjectForKey:adUnitId];
    return bidToken;
}

#pragma mark - Private

- (CRBannerAdUnit *)bannerAdUnit:(NSString *)adUnitId size:(CGSize)size {
    return [[CRBannerAdUnit alloc] initWithAdUnitId:adUnitId size:size];
}

- (CRInterstitialAdUnit *)interstitialAdUnit:(NSString *)adUnitId {
    return [[CRInterstitialAdUnit alloc] initWithAdUnitId:adUnitId];
}

- (CRAdUnit *)adUnitByFormat:(BDMAdUnitFormat)format adUnitId:(NSString *)adUnitId {
    switch (format) {
        case BDMAdUnitFormatInLineBanner: return [self bannerAdUnit:adUnitId size:CGSizeFromBDMSize(BDMBannerAdSize320x50)]; break;
        case BDMAdUnitFormatBanner320x50: return [self bannerAdUnit:adUnitId size:CGSizeFromBDMSize(BDMBannerAdSize320x50)]; break;
        case BDMAdUnitFormatBanner728x90: return [self bannerAdUnit:adUnitId size:CGSizeFromBDMSize(BDMBannerAdSize728x90)]; break;
        case BDMAdUnitFormatBanner300x250: return [self bannerAdUnit:adUnitId size:CGSizeFromBDMSize(BDMBannerAdSize300x250)]; break;
        case BDMAdUnitFormatInterstitialStatic: return [self interstitialAdUnit:adUnitId]; break;
        case BDMAdUnitFormatInterstitialVideo: return [self interstitialAdUnit:adUnitId]; break;
        case BDMAdUnitFormatInterstitialUnknown: return [self interstitialAdUnit:adUnitId]; break;
            
        default: return nil; break;
    }
}

- (CRBidResponse *)bidResponseForAdUnit:(CRAdUnit *)adUnit {
    if (!adUnit) {
        return nil;
    }
    
    CRBidResponse *bidResponse = [[Criteo sharedCriteo] getBidResponseForAdUnit:adUnit];
    return bidResponse.bidSuccess ? bidResponse : nil;
}

- (BOOL)isValidOrientation:(NSString *)orientation {
    if (!orientation ||
        (UIInterfaceOrientationIsPortrait(STKInterface.orientation) && [orientation isEqualToString:@"portrait"]) ||
        (UIInterfaceOrientationIsLandscape(STKInterface.orientation) && [orientation isEqualToString:@"landscape"])) {
        return YES;
    }
    
    return NO;
}

@end
