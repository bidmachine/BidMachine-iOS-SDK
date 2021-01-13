//
//  OpenRTB+BDMCreative.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 23.12.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMProtoAPI-Umbrella.h"

NS_ASSUME_NONNULL_BEGIN

@interface ORTBResponse_Seatbid_Bid (BDMCreative)

- (nullable ADCOMAd *)bdmAdcomAd:(NSError *__autoreleasing *)error;

- (NSDictionary *)bdmSKStoreJSONRepresentation;

@end

@interface ADCOMAd (BDMCreative)

- (nullable BDMAdExtension *)bdmAdExtension:(NSError *__autoreleasing *)error;

- (BDMHeaderBiddingAd *)bdmBannerHeaderBiddingAd;

- (BDMHeaderBiddingAd *)bdmVideoHeaderBiddingAd;

- (BDMHeaderBiddingAd *)bdmNativeHeaderBiddingAd;

@end

@interface ADCOMAd_Video (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation;

@end

@interface ADCOMAd_Display (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation;

@end

@interface ADCOMAd_Display_Native (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation;

@end

@interface BDMAdExtension (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation;

@end

@interface BDMAdExtension_ControlAsset (BDMCreative)

- (NSDictionary *)bdmJSONRepresentation;

@end


NS_ASSUME_NONNULL_END
