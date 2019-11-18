//
//  BDMFactory+BDMDisplayAd.m
//  BidMachine
//
//  Created by Stas Kochkin on 01/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMFactory+BDMDisplayAd.h"
#import "BDMFullscreenAdDisplayAd.h"
#import "BDMBannerViewDisplayAd.h"
#import "BDMNativeAdViewDisplayAd.h"
#import "BDMRequest+Private.h"
#import "NSError+BDMSdk.h"
#import <StackFoundation/StackFoundation.h>

@implementation BDMFactory (BDMDisplayAd)

- (id<BDMDisplayAd>)displayAdWithResponse:(id<BDMResponse>)response
                            plecementType:(BDMInternalPlacementType)placementType {
    id <BDMDisplayAd> displayAd;
    switch (placementType) {
        case BDMInternalPlacementTypeBanner:        displayAd = [BDMBannerViewDisplayAd displayAdWithResponse:response placementType:placementType]; break;
        case BDMInternalPlacementTypeNative:        displayAd = [BDMNativeAdViewDisplayAd displayAdWithResponse:response placementType:placementType]; break;
        case BDMInternalPlacementTypeInterstitial:  displayAd = [BDMFullscreenAdDisplayAd displayAdWithResponse:response placementType:placementType]; break;
        case BDMInternalPlacementTypeRewardedVideo: displayAd = [BDMFullscreenAdDisplayAd displayAdWithResponse:response placementType:placementType]; break;
    }
    return displayAd;
}

- (id<BDMDisplayAd>)displayAdWithRequest:(BDMRequest *)request
                                   error:(NSError *__autoreleasing *)error {
    if (!request) {
        NSError * errorObject = [NSError bdm_errorWithCode:BDMErrorCodeInternal
                                               description:@"You should pass request to ad object before try to show any ad!"];
        STK_SET_AUTORELASE_VAR(error, errorObject);
    }
    id<BDMDisplayAd> displayAd = [request displayAdWithError:error];
    // TODO: Avoid casting
    if ([displayAd isKindOfClass:BDMBannerViewDisplayAd.class] && [request isKindOfClass:BDMBannerRequest.class]) {
        [(BDMBannerViewDisplayAd *)displayAd setAdSize:[(BDMBannerRequest *)request adSize]];
    }
    return displayAd;
}

@end
