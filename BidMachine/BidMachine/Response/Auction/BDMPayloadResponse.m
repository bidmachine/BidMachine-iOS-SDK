//
//  BDMPayloadResponse.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 28.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMPayloadResponse.h"
#import "BDMFactory+BDMServerCommunicator.h"

#import <StackFoundation/StackFoundation.h>


@implementation BDMPayloadResponse

+ (instancetype)parseFromPayload:(NSString *)payload {
    NSData *payloadData = nil;
    if (!payload || !(payloadData = [[NSData alloc] initWithBase64EncodedString:payload options:0])) {
        return nil;
    }
    
    BDMResponsePayload *payloadResponse = [BDMResponsePayload parseFromData:payloadData error:nil];
    id<BDMResponse> response = [[BDMFactory sharedFactory] wrappedResponseData:payloadResponse.responseCache.data];
    NSURL *responseURL = [NSURL stk_url:payloadResponse.responseCacheURL];
    
    if (!response.creative && (!responseURL || [responseURL.absoluteString isEqual:@""])) {
        return nil;
    }
    
    BDMAdUnitFormat format = [self formatFromPlacement:payloadResponse.hasRequestItemSpec ? payloadResponse.requestItemSpec : nil];
    
    return [[self alloc] initPrivatlyWithResponse:response
                                              url:responseURL
                                           format:format];
}

- (instancetype)initPrivatlyWithResponse:(id<BDMResponse>)response
                                     url:(NSURL *)url
                                  format:(BDMAdUnitFormat)format {
    if (self = [super init]) {
        _response = response;
        _url = url;
        _format = format;
    }
    return self;
}

+ (BDMAdUnitFormat)formatFromPlacement:(ADCOMPlacement *)placement {
    if (!placement) {
        return BDMAdUnitFormatUnknown;
    }
    
    BDMAdUnitFormat format = BDMAdUnitFormatUnknown;
    if (placement.hasDisplay) {
        if (placement.display.pos == ADCOMPlacementPosition_PlacementPositionFullscreen) {
            if (placement.reward) {
                format = BDMAdUnitFormatRewardedPlayable;
            } else {
                format = BDMAdUnitFormatInterstitialStatic;
            }
        } else {
            if (placement.display.hasNativefmt) {
                format = BDMAdUnitFormatNativeAdUnknown;
            } else {
                if (placement.display.h == 50) {
                    format = BDMAdUnitFormatBanner320x50;
                } else if (placement.display.h == 90) {
                    format = BDMAdUnitFormatBanner728x90;
                } else if (placement.display.h == 250) {
                    format = BDMAdUnitFormatBanner300x250;
                }
            }
        }
    } else if (placement.hasVideo) {
        if (placement.display.pos == ADCOMPlacementPosition_PlacementPositionFullscreen) {
            if (placement.reward) {
                format = BDMAdUnitFormatRewardedVideo;
            } else {
                format = BDMAdUnitFormatInterstitialVideo;
            }
        }
    }
    return format;
}

@end
