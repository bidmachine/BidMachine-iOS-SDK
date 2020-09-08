//
//  BDMVASTNetwork.h
//  BDMVASTNetwork
//
//  Created by Pavel Dunyashev on 24/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const BDMVASTCreativeKey;
FOUNDATION_EXPORT NSString *const BDMVASTMaxDurationKey;
FOUNDATION_EXPORT NSString *const BDMVASTUseNativeCloseKey;
FOUNDATION_EXPORT NSString *const BDMVASTVideoSkipOffsetKey;
FOUNDATION_EXPORT NSString *const BDMVASTCompanionSkipOffsetKey;

@interface BDMVASTNetwork : NSObject <BDMNetwork>

@end

NS_ASSUME_NONNULL_END
