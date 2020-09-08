//
//  BDMAmazonAdLoader.m
//  BDMAmazonAdapter
//
//  Created by Stas Kochkin on 31.08.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//


@import DTBiOSSDK;
@import StackFoundation;
@import BidMachine.Adapters;

#import "BDMAmazonAdLoader.h"


#define dimension(phone, pad) UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? pad : phone


@interface BDMAmazonCallbackProxy : NSObject <DTBAdCallback>

@property (nonatomic, weak) id<DTBAdCallback> delegate;

@end


@implementation BDMAmazonCallbackProxy

- (void)onSuccess:(DTBAdResponse *)adResponse {
    [self.delegate onSuccess:adResponse];
}

- (void)onFailure:(DTBAdError)error {
    [self.delegate onFailure:error];
}

@end


@interface BDMAmazonAdLoader () <DTBAdCallback>

@property (nonatomic, strong) DTBAdLoader *loader;
@property (nonatomic, copy) BDMAmazonAdLoaderCompletion completion;
@property (nonatomic, copy) NSDictionary <NSString *, id> *parameters;
@property (nonatomic, assign) BDMAdUnitFormat format;


@end

@implementation BDMAmazonAdLoader

- (instancetype)initWithFormat:(BDMAdUnitFormat)foramt
              serverParameters:(NSDictionary<NSString *,id> *)parameters {
    if (self = [super init]) {
        self.format = foramt;
        self.parameters = parameters;
    }
    return self;
}

- (void)prepareWithCompletion:(BDMAmazonAdLoaderCompletion)completion {
    NSError *error;
    DTBAdSize *adSize = [self adSizeWithError:&error];
    if (error) {
        STK_RUN_BLOCK(completion, self, nil, error);
        return;
    }
    
    self.completion = completion;
    self.loader = [DTBAdLoader new];
    
    BDMAmazonCallbackProxy *proxy = [BDMAmazonCallbackProxy new];
    proxy.delegate = self;
    
    @try {
        [self.loader setAdSizes:@[adSize]];
        [self.loader loadAd:proxy];
    } @catch (NSException *exception) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:exception.debugDescription];
        STK_RUN_BLOCK(completion, self, nil, error);
    }
}

#pragma mark - Private

- (DTBAdSize *)adSizeWithError:(NSError **)error {
    NSString *slotUUID = ANY(self.parameters).from(BDMAmazonSlotIdKey).string;
    if (!slotUUID) {
        NSError *_error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                         description:@"Amazon adapter was not receive valid bidding data"];
        STK_SET_AUTORELASE_VAR(error, _error);
        return nil;
    }
    DTBAdSize *adSize;
    switch (self.format) {
        case BDMAdUnitFormatBanner300x250:          adSize = [[DTBAdSize alloc] initBannerAdSizeWithWidth:300 height:250 andSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatBanner320x50:           adSize = [[DTBAdSize alloc] initBannerAdSizeWithWidth:320 height:50 andSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatBanner728x90:           adSize = [[DTBAdSize alloc] initBannerAdSizeWithWidth:728 height:90 andSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatInLineBanner:           adSize = [[DTBAdSize alloc] initBannerAdSizeWithWidth:dimension(320, 728) height:dimension(50, 90) andSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatInterstitialVideo:      adSize = [[DTBAdSize alloc] initVideoAdSizeWithPlayerWidth:STKScreen.width height:STKScreen.height andSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatInterstitialStatic:     adSize = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatInterstitialUnknown:    adSize = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatRewardedVideo:          adSize = [[DTBAdSize alloc] initVideoAdSizeWithPlayerWidth:STKScreen.width height:STKScreen.height andSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatRewardedPlayable:       adSize = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID:slotUUID]; break;
        case BDMAdUnitFormatRewardedUnknown:        adSize = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID:slotUUID]; break;
    
        default: {
            NSError *_error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                             description:@"Amazon adapter was not receive valid bidding data"];
            STK_SET_AUTORELASE_VAR(error, _error);
            break;
        }
    }
    return adSize;
}

#pragma mark - DTBAdCallback

- (void)onFailure:(DTBAdError)error {
    NSError *wrapped = [NSError bdm_errorWithCode:BDMErrorCodeNoContent
                                      description:@"DTBAdLoader returned error"];
    STK_RUN_BLOCK(self.completion, self, nil, wrapped);
    self.completion = nil;
}

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
    
    STK_RUN_BLOCK(self.completion, self, bidding, nil);
    self.completion = nil;
}

@end
