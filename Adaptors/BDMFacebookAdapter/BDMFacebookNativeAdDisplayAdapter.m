//
//  BDMFacebookNativeAdDisplayAdapter.m
//  BDMFacebookAdapter
//
//  Created by Ilia Lozhkin on 11/20/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMFacebookNativeAdDisplayAdapter.h"

@import StackUIKit;
@import StackFoundation;

@interface BDMFacebookNativeAdDisplayAdapter ()<FBNativeAdDelegate>

@property (nonatomic, strong) FBNativeAd *ad;
@property(nonatomic, readwrite, copy, nonnull) NSString *title;
@property(nonatomic, readwrite, copy, nonnull) NSString *body;
@property(nonatomic, readwrite, copy, nonnull) NSString *CTAText;
@property(nonatomic, readwrite, copy, nonnull) NSString *iconUrl;
@property(nonatomic, readwrite, copy, nonnull) NSString *mainImageUrl;
@property(nonatomic, readwrite, copy, nullable) NSNumber *starRating;
@property(nonatomic, readwrite, assign) BOOL containsVideo;


@end

@implementation BDMFacebookNativeAdDisplayAdapter

+ (instancetype)displayAdapterForAd:(FBNativeAd *)ad {
    return [[self alloc] initWithNativeAd:ad];
}

- (instancetype)initWithNativeAd:(FBNativeAd *)ad {
    if (self = [super init]) {
        self.ad = ad;
    }
    return self;
}

- (void)parseAd:(FBNativeAd *)ad {
    NSDictionary *model = ANY(ad).from(@"dataModel.metadata").value;
    if (NSDictionary.stk_isValid(model)) {
        self.title = ANY(model).from(@"title").string;
        self.body = ANY(model).from(@"body").string;
        self.CTAText = ANY(model).from(@"call_to_action").string;
        self.iconUrl = ANY(model).from(@"icon.url").string;
        self.mainImageUrl = ANY(model).from(@"image.url").string;
        self.containsVideo = ad.adFormatType == FBAdFormatTypeVideo;
    }
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
    
    UIImageView *iconView = nil;
    if ([adRendering respondsToSelector:@selector(iconView)] && adRendering.iconView) {
        iconView = adRendering.iconView;
        adRendering.iconView.stkFastImageCache([NSURL URLWithString:self.iconUrl]);
    }
    
    FBMediaView *adView = nil;
    if ([adRendering respondsToSelector:@selector(mediaContainerView)] && adRendering.mediaContainerView) {
        adView = FBMediaView.new;
        [adView stk_edgesEqual:adRendering.mediaContainerView];
    }
    
    FBAdChoicesView *adChoice = nil;
    if ([adRendering respondsToSelector:@selector(adChoiceView)] && adRendering.adChoiceView) {
        adChoice = FBAdChoicesView.new;
        adChoice.backgroundShown = NO;
        [adChoice stk_edgesEqual:adRendering.adChoiceView];
    }
    
    self.ad.delegate = self;
    [self.ad registerViewForInteraction:view
                              mediaView:adView
                          iconImageView:iconView
                         viewController:controller
                         clickableViews:clickableViews];
    [self.ad downloadMedia];
    [adChoice updateFrameFromSuperview];
}

- (void)invalidate {
    [self unregisterView];
}

- (void)unregisterView {
    [self.ad unregisterView];
}

#pragma mark - FBNativeAdDelegate

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    [self.delegate nativeAdAdapterTrackUserInteraction:self];
}

@end
