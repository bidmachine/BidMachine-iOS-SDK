//
//  BDMPlacement+Builder.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 12.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMPlacement+Builder.h"
#import "BDMPlacementRequestBuilder.h"

#import <StackFoundation/StackFoundation.h>

@implementation BDMPlacement (Builder)

- (BDMPlacementRequestBuilder *)builder {
    BDMPlacementRequestBuilder *builder = [BDMPlacementRequestBuilder new];
    builder.appendSDK(@"BidMachine");
    builder.appendSDKVer(kBDMVersion);
    [self populateBuilder:builder withPlacement:self];
    return builder;
}

- (void)populateBuilder:(BDMPlacementRequestBuilder *)builder withPlacement:(BDMPlacement *)placement {
    switch (self.type) {
        case BDMInternalPlacementTypeBanner: [self populateBuilder:builder withBannerPlacement:(BDMBannerPlacement *)placement]; break;
        case BDMInternalPlacementTypeInterstitial: [self populateBuilder:builder withInterstitialPlacement:(BDMInterstitialPlacement *)placement]; break;
        case BDMInternalPlacementTypeRewardedVideo: [self populateBuilder:builder withRewardedPlacement:(BDMRewardedPlacement *)placement]; break;
        case BDMInternalPlacementTypeNative: [self populateBuilder:builder withNativeAdPlacement:(BDMNativeAdPlacement *)placement]; break;
        default: break;
    }
}

- (void)populateBuilder:(BDMPlacementRequestBuilder *)builder withBannerPlacement:(BDMBannerPlacement *)placement {
    builder.appendDisplayPlacement(({
        BDMDisplayPlacementBuilder *display = BDMDisplayPlacementBuilder.new;
        display.appendInstl(NO);
        display.appendApi(5);
        display.appendWidth(CGSizeFromBDMSize(placement.bannerType).width);
        display.appendHeight(CGSizeFromBDMSize(placement.bannerType).height);
        display.appendMimes(@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]);
        display.appendUnit(1);
        display;
    }));
}

- (void)populateBuilder:(BDMPlacementRequestBuilder *)builder withInterstitialPlacement:(BDMInterstitialPlacement *)placement {
    if (placement.interstitialType & BDMFullsreenAdTypeBanner) {
        builder.appendDisplayPlacement(({
            BDMDisplayPlacementBuilder *display = BDMDisplayPlacementBuilder.new;
            display.appendPos(7);
            display.appendInstl(YES);
            display.appendApi(5);
            display.appendUnit(1);
            display.appendWidth(STKScreen.width);
            display.appendHeight(STKScreen.height);
            display.appendMimes(@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]);
            display;
        }));
    }
    if (placement.interstitialType & BDMFullscreenAdTypeVideo) {
        builder.appendVideoPlacement(({
            BDMVideoPlacementBuilder *video = BDMVideoPlacementBuilder.new;
            video.appendPos(7);
            video.appendskip(YES);
            video.appendCType(@[@2, @3, @5, @6]);
            video.appendUnit(1);
            video.appendWidth(STKScreen.width);
            video.appendHeight(STKScreen.height);
            video.appendMimes(@[@"video/mpeg" , @"video/mp4", @"video/quicktime", @"video/avi"]);
            video.appendMaxdur(30);
            video.appendMindur(5);
            video.appendMinbitr(56);
            video.appendMaxbitr(4096);
            video.appendLinearity(1);
            video;
        }));
    }
}

- (void)populateBuilder:(BDMPlacementRequestBuilder *)builder withRewardedPlacement:(BDMRewardedPlacement *)placement {
    if (placement.rewardedType & BDMFullsreenAdTypeBanner) {
        builder.appendDisplayPlacement(({
            BDMDisplayPlacementBuilder *display = BDMDisplayPlacementBuilder.new;
            display.appendPos(7);
            display.appendInstl(YES);
            display.appendApi(5);
            display.appendUnit(1);
            display.appendWidth(STKScreen.width);
            display.appendHeight(STKScreen.height);
            display.appendMimes(@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]);
            display;
        }));
    }
    
    if (placement.rewardedType & BDMFullscreenAdTypeVideo) {
        builder.appendVideoPlacement(({
            BDMVideoPlacementBuilder *video = BDMVideoPlacementBuilder.new;
            video.appendPos(7);
            video.appendskip(false);
            video.appendCType(@[@2, @3, @5, @6]);
            video.appendUnit(1);
            video.appendWidth(STKScreen.width);
            video.appendHeight(STKScreen.height);
            video.appendMimes(@[@"video/mpeg" , @"video/mp4", @"video/quicktime", @"video/avi"]);
            video.appendMaxdur(30);
            video.appendMindur(5);
            video.appendMinbitr(56);
            video.appendMaxbitr(4096);
            video.appendLinearity(1);
            video;
        }));
    }
    builder.appendReward(YES);
}

- (void)populateBuilder:(BDMPlacementRequestBuilder *)builder withNativeAdPlacement:(BDMNativeAdPlacement *)placement {
    builder.appendDisplayPlacement(({
        BDMDisplayPlacementBuilder *display = BDMDisplayPlacementBuilder.new;
        display.appendInstl(NO);
        display.appendMimes(@[@"image/jpeg", @"image/jpg", @"image/gif", @"image/png"]);
        display.appendNativeFmt(({
            BDMNativeFormatBuilder *native = BDMNativeFormatBuilder.new;
            native.appendTitle(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(123);
                fmt.appendReq(1);
                fmt;
            }))
            .appendIcon(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(124);
                fmt.appendReq(placement.nativeAdType & BDMNativeAdTypeIcon);
                fmt;
            }))
            .appendImage(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(128);
                fmt.appendReq(placement.nativeAdType & BDMNativeAdTypeImage);
                fmt;
            }))
            .appendDescription(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(127);
                fmt.appendReq(1);
                fmt;
            }))
            .appendCta(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(8);
                fmt.appendReq(1);
                fmt;
            }))
            .appendRating(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(7);
                fmt.appendReq(0);
                fmt;
            }))
            .appendSponsored(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(0);
                fmt.appendReq(0);
                fmt;
            }))
            .appendVideo(({
                BDMNativeFormatTypeBuilder *fmt = BDMNativeFormatTypeBuilder.new;
                fmt.appendId(4);
                fmt.appendReq(placement.nativeAdType & BDMNativeAdTypeVideo);
                fmt;
            }));
            native;
        }));
        display;
    }));
}

@end
