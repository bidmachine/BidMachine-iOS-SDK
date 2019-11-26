//
//  BDMAdNetworkConfiguration.h
//  BidMachine
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMNetworkProtocol.h>
#import <BidMachine/BDMAdUnit.h>


NS_ASSUME_NONNULL_BEGIN


@class BDMAdNetworkConfiguration;
/**
 Builder for Ad network configuration
 */
@interface BDMAdNetworkConfigurationBuilder : NSObject
/**
 Adds network name, registered in ad network adapter and backend. Required
 */
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendName)(NSString *);
/**
 Adds class of BDMNetwork. Required
 */
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendNetworkClass)(Class<BDMNetwork>);
/**
 Adds network ad units that contain info about
 ad format and network specific parameters. Required
 */
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendAdUnit)(BDMAdUnitFormat, NSDictionary <NSString *, id> *);
/**
 Adds network specific parameters. Optional
 */
@property (nonatomic, copy, readonly) BDMAdNetworkConfigurationBuilder *(^appendInitializationParams)(NSDictionary <NSString *, id> *);
@end


/**
 Ad network configuration for network
 */
@interface BDMAdNetworkConfiguration : NSObject <NSSecureCoding, NSCopying>
/**
 Network name, registered in ad network adapter and backend. Required
 */
@property (nonatomic, copy, readonly) NSString *name;
/**
 Class of BDMNetwork. Required
 */
@property (nonatomic, copy, readonly) Class<BDMNetwork> networkClass;
/**
 Network ad units that contain info about
 ad format and network specific parameters. Required
 */
@property (nonatomic, copy, readonly) NSArray <BDMAdUnit *> *adUnits;
/**
 Network specific parameters. Optional
 */
@property (nonatomic, copy, readonly) NSDictionary <NSString *, id> *initializationParams;
/**
 Timeout for network placement preparation before auction request
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeout;
/**
 Builds configuration for ad network adapter
 
 @param builder Builder block
 @return Configuration
 */
+ (nullable instancetype)buildWithBuilder:(void(^)(BDMAdNetworkConfigurationBuilder *))builder;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
