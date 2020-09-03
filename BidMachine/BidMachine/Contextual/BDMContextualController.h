//
//  BDMContextualController.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMContextualProtocol.h"
#import "BDMEventObject.h"


NS_ASSUME_NONNULL_BEGIN

@interface BDMContextualController : NSObject

- (void)start;

- (void)registerImpressionForPlacement:(BDMInternalPlacementType)placement;

- (void)registerClickForPlacement:(BDMInternalPlacementType)placement;

- (void)registerCompletionForPlacement:(BDMInternalPlacementType)placement;

- (void)registerLastBundle:(nullable NSString *)lastBundle forPlacement:(BDMInternalPlacementType)placement;

- (void)registerLastAdomain:(nullable NSString *)lastAdomain forPlacement:(BDMInternalPlacementType)placement;

- (nullable id<BDMContextualProtocol>)contextualDataForPlacement:(BDMInternalPlacementType)placement;

@end

NS_ASSUME_NONNULL_END
