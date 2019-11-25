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
/// @param view Presented view
/// @param clickableViews Custom clickable views
/// @param adRendering Native ad rendering object that conforms BDMNativeAdRendering
/// @param controller Root view controller
/// @param error Autorelease error return syncronized error ( validate or throw exception )
- (void)presentOn:(nonnull UIView *)view
   clickableViews:(NSArray<UIView *> *)clickableViews
      adRendering:(id <BDMNativeAdRendering>)adRendering
       controller:(UIViewController *)controller
            error:(NSError * __autoreleasing*)error;
/// Current Native ad assets
- (id<BDMNativeAdAssets>)assets;
/// Unregister native ad views. Call this method before reuse native
- (void)unregisterViews;

@end

NS_ASSUME_NONNULL_END


