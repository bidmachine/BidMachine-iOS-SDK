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

__deprecated_msg("Will be removed in future versions")
@protocol BDMFetcherProtocol <NSObject>

/// Set the rounding format here
- (NSString *)format;

/// Set the rounding mode here
- (NSNumberFormatterRoundingMode)roundingMode;

@end

__deprecated_msg("Will be removed in future versions")
@protocol BDMFetcherPresetProtocol <BDMFetcherProtocol>

- (BDMInternalPlacementType)type;

- (BDMFetcherRange)range;

@end

__deprecated_msg("Will be removed in future versions")
@interface BDMDefaultFetcherPresset : NSObject <BDMFetcherPresetProtocol>

@property (nonatomic, strong) NSString *format;
@property (nonatomic, assign) NSNumberFormatterRoundingMode roundingMode;
@property (nonatomic, assign) BDMInternalPlacementType type;
@property (nonatomic, assign) BDMFetcherRange range;

- (void)registerPresset;

@end

__deprecated_msg("Will be removed in future versions")
@interface BDMFetcher : NSObject
/// Singletone fetcher
+ (instancetype)shared;
/// Register fetcher settings
/// Support for custom settings is removed in newer versions
/// All rounding will happen on the server side
/// @param preset Fetcher presset settings
- (void)registerPresset:(id<BDMFetcherPresetProtocol>)preset;

@end

@interface BDMFetcher (Request)
/// Return fetched params
/// Will be removed in future versions
/// Use (BDMRequestStorage saveRequest:) in order to save the request
/// Use (BDMRequest.info.customParams) in order to get custom parameters
/// @param request Current request
- (nullable NSDictionary *)fetchParamsFromRequest:(nullable BDMRequest *)request ;
/// Return fetched params
/// Will be removed in future versions
/// Use (BDMRequestStorage saveRequest:) in order to save the request
/// Use (BDMRequest.info.customParams) in order to get custom parameters
/// @param request Current request
/// @param fetcher Custom fetcher
- (nullable NSDictionary *)fetchParamsFromRequest:(nullable BDMRequest *)request
                                          fetcher:(nullable id<BDMFetcherProtocol>)fetcher;

@end

NS_ASSUME_NONNULL_END
