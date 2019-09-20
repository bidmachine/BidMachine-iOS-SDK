//
//  BDMAmazonUtils.m
//  BDMAmazonAdapter
//
//  Created by Yaroslav Skachkov on 9/11/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import DTBiOSSDK;

#import "BDMAmazonUtils.h"

@interface BDMAmazonUtils()

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *slotUUIDs;

@end

@implementation BDMAmazonUtils

+ (instancetype)sharedInstance {
    static BDMAmazonUtils * _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = BDMAmazonUtils.new;
    });
    return _sharedInstance;
}

+ (NSDictionary<NSString *,id> *)biddingInformation:(NSDictionary<NSString *,id> *)loadingParams {
    return NSDictionary.new;
}

- (void)configureSlotsDict:(NSDictionary *)dict {
    NSMutableArray *adUnits = dict[@"ad_units"];
    self.slotUUIDs = NSMutableDictionary.new;
    for (NSDictionary *adUnit in adUnits) {
        self.slotUUIDs[adUnit[@"slot_uuid"]] = adUnit[@"format"];
    }
}

- (NSArray<DTBAdSize *> *)configureAdSizesWith:(NSString *)slotUUID {
    NSString *adType = self.slotUUIDs[slotUUID];
    DTBAdSize *adSize = [self configureAdSizeWith:slotUUID adType:adType];
    NSMutableArray *adSizes = [NSMutableArray arrayWithObject:adSize];
    return adSizes;
}

- (DTBAdSize *)configureAdSizeWith:(NSString *)slotUUID adType:(NSString *)adType {
    CGSize size;
    DTBAdSize *adSize;
    if ([adType isEqualToString:@"banner"]) {
        size = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? CGSizeMake(728, 90) : CGSizeMake(320, 50);
    } else if ([adType isEqualToString:@"banner_300x250"]) {
        size = CGSizeMake(300, 250);
    } else if ([adType isEqualToString:@"banner_320x50"]) {
        size = CGSizeMake(320, 50);
    } else if ([adType isEqualToString:@"banner_728x90"]) {
        size = CGSizeMake(728, 90);
    } else if ([adType isEqualToString:@"interstitial"] || [adType isEqualToString:@"interstitial_static"]) {
        return [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID: slotUUID];
    } else if ([adType isEqualToString:@"interstitial_video"]) {
        size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        return [[DTBAdSize alloc] initVideoAdSizeWithPlayerWidth:size.width height:size.height andSlotUUID:slotUUID];
    }
    adSize = [[DTBAdSize alloc] initBannerAdSizeWithWidth:size.width height:size.height andSlotUUID:slotUUID];
    return adSize;
}

@end
