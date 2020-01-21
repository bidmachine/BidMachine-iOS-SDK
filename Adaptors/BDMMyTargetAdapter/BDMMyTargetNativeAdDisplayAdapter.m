//
//  BDMMyTargetNativeAdDisplayAdapter.m
//  BDMMyTargetAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMyTargetNativeAdDisplayAdapter.h"

@import StackUIKit;
@import StackFoundation;

@interface BDMMyTargetNativeAdDisplayAdapter ()<MTRGNativeAdDelegate>

@property (nonatomic, strong) MTRGNativeAd *ad;

@end

@implementation BDMMyTargetNativeAdDisplayAdapter

+ (instancetype)displayAdapterForAd:(MTRGNativeAd *)ad {
    return [[self alloc] initWithNativeAd:ad];
}

- (instancetype)initWithNativeAd:(MTRGNativeAd *)ad {
    if (self = [super init]) {
        self.ad = ad;
    }
    return self;
}

#pragma mark - BDMNativeAdAssets

- (NSString *)title {
    return self.ad.banner.title;
}

- (NSString *)body {
    return self.ad.banner.descriptionText;
}

- (NSString *)CTAText {
    return self.ad.banner.ctaText;
}

- (NSString *)iconUrl {
    return self.ad.banner.icon.url;
}

- (NSString *)mainImageUrl {
    return self.ad.banner.image.url;
}

- (NSNumber *)starRating {
    return self.ad.banner.rating;
}

- (BOOL)containsVideo {
    return self.ad.banner.hasVideo;
}

#pragma mark - BDMNativeAd

- (void)presentOn:(UIView *)view
   clickableViews:(NSArray<UIView *> *)clickableViews
      adRendering:(id<BDMNativeAdRendering>)adRendering
       controller:(UIViewController *)controller
{
    adRendering.titleLabel.text = self.title;
    adRendering.callToActionLabel.text = self.CTAText;
    adRendering.descriptionLabel.text = self.body;
    
    
    if ([adRendering respondsToSelector:@selector(iconView)] && adRendering.iconView) {
        adRendering.iconView.stkFastImageCache([NSURL URLWithString:self.iconUrl]);
    }
    
    if ([adRendering respondsToSelector:@selector(mediaContainerView)] && adRendering.mediaContainerView) {
        MTRGContentStreamAdView *adView = [MTRGContentStreamAdView createWithBanner:self.ad.banner];
        [adView loadImages];
        [self.ad registerView:adView withController:controller];
        [adView removeFromSuperview];
        [adView stk_edgesEqual:adRendering.mediaContainerView];
        
    }
    
    self.ad.delegate = self;
    [self.ad registerView:view withController:controller];
    
}

- (void)invalidate {
    [self unregisterView];
}

- (void)unregisterView {
    [self.ad unregisterView];
}

#pragma mark - MTRGNativeAdDelegate

- (void)onLoadWithNativePromoBanner:(MTRGNativePromoBanner *)promoBanner nativeAd:(MTRGNativeAd *)nativeAd {
    // no-op
}

- (void)onNoAdWithReason:(NSString *)reason nativeAd:(MTRGNativeAd *)nativeAd {
    //no-op
}

- (void)onAdClickWithNativeAd:(MTRGNativeAd *)nativeAd {
    [self.delegate nativeAdAdapterTrackUserInteraction:self];
}

@end
