//
//  NSArray+BDMExtension.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 16.01.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BDMEventURL.h"
#import "BDMAdNetworkConfiguration.h"


@interface NSArray (BDMEventURL)

- (BDMEventURL *)bdm_searchTrackerOfType:(NSInteger)type;

@end


@interface NSArray (BDMAdNetworkConfiguration)

- (NSArray <BDMAdNetworkConfiguration *> *)bdm_configurationConcat:(NSArray <BDMAdNetworkConfiguration *> *)configuration;

@end
