//
//  BDMExternalAdapterConfiguration.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 21.01.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMExternalAdapterConfigurationProtocol.h>
#import <BidMachine/BDMExternalAdapterConfigurationBuilderProtocol.h>

NS_ASSUME_NONNULL_BEGIN


@interface BDMExternalAdapterConfiguration : NSObject
<BDMExternalAdapterInitialConfigurationProtocol,
BDMExternalAdapterTargetingConfigurationProtocol,
BDMExternalAdapterPublisherConfigurationProtocol,
BDMExternalAdapterRestrictionConfigurationProtocol,
BDMExternalAdapterRequestConfigurationProtocol>

+ (instancetype)configurationWithBuilder:(void(^)(id<BDMExternalAdapterConfigurationBuilderProtocol>))builder;

- (NSDictionary *)jsonConfiguration;

+ (instancetype)new __unavailable;

- (instancetype)init __unavailable;

@end

NS_ASSUME_NONNULL_END
