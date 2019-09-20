//
//  BDMAmazonUtils.h
//  BDMAmazonAdapter
//
//  Created by Yaroslav Skachkov on 9/11/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

NS_ASSUME_NONNULL_BEGIN

static NSString * const kAmazonConsentString = @"consent_string";
static NSString * const kAmazonKey = @"amazon_key";
static NSString * const kAmazonSlotUUID = @"slot_uuid";

@interface BDMAmazonUtils : NSObject

+ (instancetype)sharedInstance;
+ (NSDictionary<NSString *, id> *)biddingInformation:(NSDictionary<NSString *, id> *)loadingParams;
- (void)configureSlotsDict:(NSDictionary *)dict;
- (NSArray<DTBAdSize *> *)configureAdSizesWith:(NSString *)slotUUID;

@end

NS_ASSUME_NONNULL_END
