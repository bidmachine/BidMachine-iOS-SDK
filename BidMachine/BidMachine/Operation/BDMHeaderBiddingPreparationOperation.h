//
//  BDMHeaderBiddingTransformOperation.h
//  BidMachine
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BDMPlacementAdUnit.h"
#import "BDMAdNetworkConfiguration.h"
#import "BDMHeaderBiddingOperationProtocol.h"
#import "BDMHeaderBiddingController.h"
#import "BDMAsyncOperation.h"
#import "BDMRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

@interface BDMHeaderBiddingPreparationOperation : BDMAsyncOperation <BDMHeaderBiddingOperation>

@property (nonatomic, copy, readonly) NSArray <id<BDMPlacementAdUnit>> *result;

+ (instancetype)preparationOperationForNetworks:(NSArray <BDMAdNetworkConfiguration *> *)networks
                                     controller:(BDMHeaderBiddingController *)controller
                                      placement:(BDMPlacement *)placement;

@end

NS_ASSUME_NONNULL_END
