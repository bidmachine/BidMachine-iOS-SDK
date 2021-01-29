//
//  BDMAdNetworkConfiguration.h
//  BidMachine
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <BidMachine/BDMAdUnit.h>
#import <BidMachine/BDMNetworkProtocol.h>


NS_ASSUME_NONNULL_BEGIN


@class BDMAdNetworkConfiguration;
/// Builder for Ad network configuration
@interface BDMAdNetworkConfigurationBuilder : NSObject

///<--- Required --->

/// Adds network name, registered in ad network adapter and backend. Required
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendName)(NSString *);
/// Adds class of BDMNetwork. Required
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendNetworkClass)(Class<BDMNetwork>);

///<--- Optional --->

/// Timeout for network placement preparation before auction request. Optional
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendTimeout)(NSTimeInterval);
/// Adds network specific parameters. Optional
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendParams)(BDMStringToStringMap *);
/// Adds network ad units that contain info about
/// ad format and network specific parameters and extras parameters. Optional
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendAdUnit)(BDMAdUnitFormat, BDMStringToStringMap *, BDMStringToObjectMap *_Nullable);
@end

/// Ad network configuration for network
@interface BDMAdNetworkConfiguration : NSObject <NSSecureCoding, NSCopying>
/// Network name, registered in ad network adapter and backend. Required
@property (nonatomic, copy, readonly) NSString *name;
/// Class of BDMNetwork. Required
@property (nonatomic, copy, readonly) Class<BDMNetwork> networkClass;
/// Timeout for network placement preparation before auction request
@property (nonatomic, assign, readonly) NSTimeInterval timeout;
/// Network specific parameters. Optional
@property (nonatomic, copy, readonly) BDMStringToStringMap *params;
/// Network ad units that contain info about
/// ad format and network specific parameters. Required
@property (nonatomic, copy, readonly) NSArray <BDMAdUnit *> *adUnits;
/// Builds configuration for ad network adapter
/// @param builder Builder block
+ (nullable instancetype)buildWithBuilder:(void(^)(BDMAdNetworkConfigurationBuilder *))builder;
// Create configuration from JSON
//"network": "name",                            // required unique network name
//"network_class": "BDMNetworkClass",           // required network class name
//"timeout": 5000,                              // optional time in ms
//"params" : { String to String map },          // optional network initalize params
//"ad_units": [{
//  "format": "interstitial",                   // required can be: unknown,
//                                              banner, banner_320x50, banner_728x90, banner_300x250
//                                              interstitial_video, interstitial_static, interstitial
//                                              rewarded_video, rewarded_static, rewarded
//
//  "params" : { String to String map },        // optional network prepare params
//  "custom_params" : { String to Object map }  // optional publisher params. Back in request.auctionInfo.customParams
//  }]
+ (nullable instancetype)configurationWithJSON:(nullable BDMStringToObjectMap *)json;

- (BDMStringToObjectMap *)jsonConfiguration;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
