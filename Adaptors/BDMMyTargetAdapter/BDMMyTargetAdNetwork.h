//
//  BDMMyTargetAdNetwork.h
//  BDMMyTargetAdapter
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

@import Foundation;
@import BidMachine;
@import BidMachine.Adapters;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMMyTargetSlotIDKey;
FOUNDATION_EXPORT NSString *const BDMMyTargetBidIDKey;
FOUNDATION_EXPORT NSString *const BDMMyTargetBidTokenKey;

@interface BDMMyTargetAdNetwork : NSObject <BDMNetwork>

@end

NS_ASSUME_NONNULL_END

