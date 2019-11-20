//
//  BDMMintegralNativeAdDisplayAdapter.m
//  BDMMintegralAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMMintegralNativeAdDisplayAdapter.h"

#import <StackUIKit/StackUIKit.h>
#import <StackFoundation/StackFoundation.h>
#import <MTGSDK/MTGAdChoicesView.h>

@interface BDMMintegralNativeAdDisplayAdapter() <MTGBidNativeAdManagerDelegate>

@property (nonatomic, strong) MTGCampaign *ad;
@property (nonatomic, strong) MTGBidNativeAdManager *adManager;
@property (nonatomic,  weak) UIView *containerView;

@end

@implementation BDMMintegralNativeAdDisplayAdapter

+ (instancetype)displayAdapterForAd:(MTGCampaign *)ad manager:(MTGBidNativeAdManager *)manager {
    return [[self alloc] initWithNativeAd:ad manager:manager];
}

- (instancetype)initWithNativeAd:(MTGCampaign *)ad manager:(MTGBidNativeAdManager *)manager {
    if (self = [super init]) {
        self.ad = ad;
        self.adManager = manager;
    }
    return self;
}

#pragma mark - BDMNativeAdAssets

- (NSString *)title {
    return self.ad.appName;
}

- (NSString *)body {
    return self.ad.appDesc;
}

- (NSString *)CTAText {
    return self.ad.adCall;
}

- (NSString *)iconUrl {
    return self.ad.iconUrl;
}

- (NSString *)mainImageUrl {
    return self.ad.imageUrl;
}

- (NSNumber *)starRating {
    return nil;
}

- (BOOL)containsVideo {
    return ANY(self.ad).from(@"videoLength").number.floatValue > 0;
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
        MTGMediaView *adView = [[MTGMediaView alloc] initWithFrame:(CGRect){160, 90}];
        [adView setMediaSourceWithCampaign:self.ad unitId:self.adManager.currentUnitId];
        [adView stk_edgesEqual:adRendering.mediaContainerView];
    }
    
    if ([adRendering respondsToSelector:@selector(adChoiceView)] && adRendering.adChoiceView) {
        MTGAdChoicesView *adChoice = [[MTGAdChoicesView alloc] initWithFrame:adRendering.adChoiceView.bounds];
        [adChoice stk_edgesEqual:adRendering.adChoiceView];
        [adChoice setCampaign:self.ad];
    }
    
    self.containerView = view;
    self.adManager.viewController = controller;
    self.adManager.delegate = self;
    [self.adManager registerViewForInteraction:view withCampaign:self.ad];
}

- (void)invalidate {
    [self.adManager unregisterView:self.containerView];
}

#pragma mark - MTGBidNativeAdManagerDelegate

- (void)nativeAdDidClick:(nonnull MTGCampaign *)nativeAd bidNativeManager:(nonnull MTGBidNativeAdManager *)bidNativeManager {
    [self.delegate nativeAdAdapterTrackUserInteraction:self];
}

@end
