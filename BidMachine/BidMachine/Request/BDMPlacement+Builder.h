//
//  BDMPlacement+Builder.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 12.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMPlacement.h"
#import "BDMPlacementRequestBuilderProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface BDMPlacement (Builder)

- (id<BDMPlacementRequestBuilder>)builder;

@end

NS_ASSUME_NONNULL_END
