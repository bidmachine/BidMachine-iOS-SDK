//
//  BDMAmazonBannerAdapter.m
//  BDMAmazonAdapter
//
//  Created by Yaroslav Skachkov on 9/10/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMAmazonBannerAdapter.h"

@import DTBiOSSDK;
@import StackFoundation;
@import StackUIKit;

@interface BDMAmazonBannerAdapter()

@end

@implementation BDMAmazonBannerAdapter

- (UIView *)adView {
    return UIView.new;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {}

- (void)presentInContainer:(UIView *)container {}


@end
