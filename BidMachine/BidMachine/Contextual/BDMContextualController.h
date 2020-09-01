//
//  BDMContextualController.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 31.08.2020.
//  Copyright © 2020 Appodeal. All rights reserved.
//

#import "BDMContextualProtocol.h"
#import "BDMContextualData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BDMContextualController : NSObject

- (void)start;

- (void)saveContextualData:(id<BDMContextualProtocol>)contextualData;

- (void)saveLastBundle:(nullable NSString *)lastBundle forPlacement:(BDMInternalPlacementType)placement;

- (void)saveLastAdomain:(nullable NSString *)lastAdomain forPlacement:(BDMInternalPlacementType)placement;

- (BDMContextualData *)contextualDataWithUserData:(nullable BDMContextualData *)userData;

@end

NS_ASSUME_NONNULL_END
