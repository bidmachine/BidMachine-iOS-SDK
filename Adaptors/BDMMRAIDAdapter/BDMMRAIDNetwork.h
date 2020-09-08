//
//  BDMMRAIDNetwork.h
//  BDMMRAIDNetwork
//
//  Created by Pavel Dunyashev on 11/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMMRAIDCreativeKey;
FOUNDATION_EXPORT NSString *const BDMMRAIDSkipOffsetKey;
FOUNDATION_EXPORT NSString *const BDMMRAIDNativeCloseKey;

@interface BDMMRAIDNetwork : NSObject <BDMNetwork>

@end

NS_ASSUME_NONNULL_END
