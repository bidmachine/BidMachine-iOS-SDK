//
//  BDMNativeAdViewDisplayAd.h
//  BidMachine
//
//  Created by Stas Kochkin on 31/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMBaseDisplayAd.h"
#import "BDMNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

/// Native custom class display ad
@interface BDMNativeAdViewDisplayAd : BDMBaseDisplayAd
/// Call method to start rendering ad
/// @param renderingAd Rendering container
/// @param controller Root view controller
/// @param error Autorelease error return syncronized error ( validate, reachability or throw exception )
- (void)presentOn:(id <BDMNativeAdRendering>)renderingAd
       controller:(UIViewController *)controller
            error:(NSError * __autoreleasing*)error;

@end

NS_ASSUME_NONNULL_END


