//
//  BDMExternalAdapterRequestController.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 26.01.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMExternalAdapterRequestController.h"
#import "BDMExternalAdapterSDKController.h"

#import <StackFoundation/StackFoundation.h>

@interface BDMExternalAdapterRequestController ()

@property (nonatomic, weak) id<BDMExternalAdapterRequestControllerDelegate> delegate;
@property (nonatomic, assign) BDMInternalPlacementType type;

@end

@implementation BDMExternalAdapterRequestController

- (instancetype)initWithType:(BDMInternalPlacementType)type delegate:(id<BDMExternalAdapterRequestControllerDelegate>)delegate {
    if (self = [super init]) {
        _type                   = type;
        _delegate               = delegate;
        _autoInitializeIfNeeded = YES;
    }
    return self;
}

- (void)prepareRequestWithConfiguration:(BDMExternalAdapterConfiguration *)configuration {
    BOOL isPrebid = [BDMRequestStorage.shared isPrebidRequestsForType:self.type];
    
    if (isPrebid && configuration.requestPrice) {
        BDMRequest *auctionRequest = [BDMRequestStorage.shared requestForPrice:configuration.requestPrice type:self.type];
        if ([self request:auctionRequest isKindOfType:self.type]) {
            [self.delegate controller:self didPrepareRequest:auctionRequest];
        } else {
            NSError *error = [STKError errorWithDescription:@"Bidmachine can't fint prebid request"];
            [self.delegate controller:self didFailPrepareRequest:error];
        }
    } else {
        __weak typeof(self) weakSelf = self;
        [BDMExternalAdapterSDKController.shared startControllerWithConfiguration:configuration completion:^(NSError *error) {
            if (error) {
                [weakSelf.delegate controller:weakSelf didFailPrepareRequest:error];
            } else {
                BDMRequest *auctionRequest = [weakSelf requestWithType:weakSelf.type configuration:configuration];
                [weakSelf.delegate controller:weakSelf didPrepareRequest:auctionRequest];
            }
        }];
    }
}

#pragma mark - Private

- (BOOL)request:(BDMRequest *)request isKindOfType:(BDMInternalPlacementType)type {
    Class typeClass;
    switch (type) {
        case BDMInternalPlacementTypeInterstitial:      typeClass = BDMInterstitialRequest.self; break;
        case BDMInternalPlacementTypeBanner:            typeClass = BDMBannerRequest.self; break;
        case BDMInternalPlacementTypeRewardedVideo:     typeClass = BDMRewardedRequest.self; break;
        case BDMInternalPlacementTypeNative:            typeClass = BDMNativeAdRequest.self; break;
        default: break;
    }
    return [request isKindOfClass:typeClass];
}

- (BDMRequest *)requestWithType:(BDMInternalPlacementType)type
                  configuration:(id<BDMExternalAdapterRequestConfigurationProtocol>)configuration {
    BDMRequest *auctionRequest = nil;
    switch (type) {
        case BDMInternalPlacementTypeInterstitial:  auctionRequest = ({
            BDMInterstitialRequest *request = BDMInterstitialRequest.new;
            request.type = configuration.fullscreenType;
            request;
        }); break;
        case BDMInternalPlacementTypeBanner:            auctionRequest = ({
            BDMBannerRequest *request = BDMBannerRequest.new;
            [request setAdSize: [self bannerSizeFromSize:configuration.adSize]];
            request;
        }); break;
        case BDMInternalPlacementTypeRewardedVideo:     auctionRequest = ({
            BDMRewardedRequest *request = BDMRewardedRequest.new;
            request;
        }); break;
        case BDMInternalPlacementTypeNative:            auctionRequest = ({
            BDMNativeAdRequest *request = BDMNativeAdRequest.new;
            request.type = configuration.nativeAdType;
            request;
        }); break;
        default: break;
    }
    auctionRequest.priceFloors = configuration.priceFloors;
    return auctionRequest;
}

- (BDMBannerAdSize)bannerSizeFromSize:(CGSize)size {
    BDMBannerAdSize adSize;
    switch ((int)size.height) {
        case 50:  adSize = BDMBannerAdSize320x50;   break;
        case 90:  adSize = BDMBannerAdSize728x90;   break;
        case 250: adSize = BDMBannerAdSize300x250;  break;
        default:  adSize = BDMBannerAdSizeUnknown;  break;
    }
    return adSize;
}

@end
