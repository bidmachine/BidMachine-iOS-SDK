//
//  BDMAmazonAdLoader.m
//  BDMAmazonAdapter
//
//  Created by Stas Kochkin on 31.08.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

#import "BDMAmazonAdLoader.h"
#import "BDMAmazonUtils.h"
#import "BDMAmazonValueTransformer.h"

@import BidMachine.Adapters;
@import StackFoundation;
@import DTBiOSSDK;


@interface BDMAmazonAdLoader () <DTBAdCallback>

@property (nonatomic, strong) DTBAdLoader *loader;
@property (nonatomic, copy) BDMAmazonAdLoaderCompletion completion;
@property (nonatomic, copy) NSDictionary <NSString *, id> *parameters;

@end

@implementation BDMAmazonAdLoader

- (instancetype)initWithServerParameters:(NSDictionary<NSString *,id> *)parameters {
    if (self = [super init]) {
        self.parameters = parameters;
    }
    return self;
}

- (void)prepareWithCompletion:(BDMAmazonAdLoaderCompletion)completion {
    NSString *slotUUID = [BDMAmazonValueTransformer.new transformedValue:self.parameters[@"slot_uuid"]];
    if (!slotUUID) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeHeaderBiddingNetwork
                                        description:@"Amazon adapter was not receive valid bidding data"];
        STK_RUN_BLOCK(completion, self, nil, error);
        return;
    }
    NSArray<DTBAdSize *> *adSizes = [BDMAmazonUtils.sharedInstance configureAdSizesWith:slotUUID];
    self.completion = completion;
    self.loader = [DTBAdLoader new];
    [self.loader setAdSizes:adSizes];
    [self.loader loadAd:self];
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
