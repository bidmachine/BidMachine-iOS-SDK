//
//  BDMFetcher.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 27.07.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>
#import <BidMachine/BDMRequest.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct BDMFetcherRange {
    float location;
    float length;
} BDMFetcherRange;

BDMFetcherRange BDMFetcherRangeMake(float _location, float _length);

@protocol BDMFetcherProtocol <NSObject>

/// Set the rounding format here
- (NSString *)format;

/// Set the rounding mode here
- (NSNumberFormatterRoundingMode)roundingMode;

@end

@protocol BDMFetcherPresetProtocol <BDMFetcherProtocol>

- (BDMInternalPlacementType)type;

- (BDMFetcherRange)range;

@end

@interface BDMFetcher : NSObject

+ (instancetype)shared;

- (void)registerPresset:(id<BDMFetcherPresetProtocol>)preset;

@end

@interface BDMFetcher (Request)
/**
 Return fetched params
*/
- (nullable NSDictionary *)fetchParamsFromRequest:(nullable BDMRequest *)request;
/**
 Return fetched params
*/
- (nullable NSDictionary *)fetchParamsFromRequest:(nullable BDMRequest *)request fetcher:(nullable id<BDMFetcherProtocol>)fetcher;

@end

NS_ASSUME_NONNULL_END
