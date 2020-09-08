//
//  BDMVASTVideoAdapter.h
//  BDMVASTVideoAdapter
//
//  Created by Pavel Dunyashev on 24/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

@import Foundation;
@import BidMachine.Adapters;


NS_ASSUME_NONNULL_BEGIN

@interface BDMVASTVideoAdapter : NSObject <BDMFullscreenAdapter>

@property (nonatomic, assign) BOOL rewarded;
@property (nonatomic,   weak) id <BDMAdapterLoadingDelegate> loadingDelegate;
@property (nonatomic,   weak) id <BDMFullscreenAdapterDisplayDelegate> displayDelegate;

@end

NS_ASSUME_NONNULL_END
