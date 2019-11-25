//
//  BDMNASTDisplayAdapter.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMNASTDisplayAdapter.h"

@import StackUIKit;
@import StackFoundation;
@import StackRichMedia;


@interface BDMNASTRichMediaAsset : STKVASTAsset <STKRichMediaAsset>

@property (nonatomic, copy) NSURL *placeholderImageURL;

+ (instancetype)assetWithNastAd:(STKNASTAd *)nastAd;

@end

@interface BDMNASTDisplayAdapter ()<STKRichMediaPlayerViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) STKNASTAd *ad;
@property (nonatomic, strong) BDMNASTRichMediaAsset *asset;
@property (nonatomic, strong) STKRichMediaPlayerView *richMedia;
@property (nonatomic, strong) NSMutableArray<UITapGestureRecognizer *> *gestures;

@end

@implementation BDMNASTDisplayAdapter

+ (instancetype)displayAdapterForAd:(STKNASTAd *)ad {
    return [[self alloc] initWithNativeAd:ad];
}

- (instancetype)initWithNativeAd:(STKNASTAd *)ad {
    if (self = [super init]) {
        self.ad = ad;
        self.asset = [BDMNASTRichMediaAsset assetWithNastAd:ad];
        self.gestures = [NSMutableArray new];
    }
    return self;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerTap)];
    gesture.numberOfTouchesRequired = 1;
    return gesture;
}

#pragma mark - BDMNativeAdAssets

- (NSString *)title {
    return self.ad.title;
}

- (NSString *)body {
    return self.ad.descriptionText;
}

- (NSString *)CTAText {
    return self.ad.callToAction;
}

- (NSString *)iconUrl {
    return self.ad.iconURLString;
}

- (NSString *)mainImageUrl {
    return self.ad.mainURLString ?: self.ad.iconURLString;
}

- (NSNumber *)starRating {
    return self.ad.starRating;
}

- (BOOL)containsVideo {
    return self.asset.contentURL != nil;
}

- (STKRichMediaPlayerView *)richMedia {
    if (!_richMedia) {
        _richMedia = STKRichMediaPlayerView.new;
        _richMedia.delegate = self;
    }
    return _richMedia;
}

#pragma mark - BDMNativeAd

- (void)presentOn:(UIView *)view
   clickableViews:(NSArray<UIView *> *)clickableViews
      adRendering:(id<BDMNativeAdRendering>)adRendering
       controller:(UIViewController *)controller
{
    adRendering.titleLabel.text = self.ad.title;
    adRendering.callToActionLabel.text = self.ad.callToAction;
    adRendering.descriptionLabel.text = self.ad.descriptionText;
    
    if ([adRendering respondsToSelector:@selector(iconView)] && adRendering.iconView) {
        adRendering.iconView.stkFastImageCache([NSURL URLWithString:self.ad.iconURLString]);
    }
    
    if ([adRendering respondsToSelector:@selector(mediaContainerView)] && adRendering.mediaContainerView) {
        [self.richMedia stk_edgesEqual:adRendering.mediaContainerView];
        self.richMedia.rootViewController = controller;
        [self.richMedia playAsset:self.asset];
    }
    
    
    adRendering.titleLabel.userInteractionEnabled = YES;
    [adRendering.titleLabel addGestureRecognizer:self.tapGestureRecognizer];
    
    adRendering.callToActionLabel.userInteractionEnabled = YES;
    [adRendering.callToActionLabel addGestureRecognizer:self.tapGestureRecognizer];
    
    // Clicks
    [clickableViews enumerateObjectsUsingBlock:^(UIView * tapView, NSUInteger idx, BOOL * stop) {
        UITapGestureRecognizer *gesture = [self tapGestureRecognizer];
        tapView.userInteractionEnabled = YES;
        [tapView addGestureRecognizer:gesture];
        [self.gestures addObject:gesture];
    }];
    
}

- (void)invalidate {
    [self unregisterView];
}

- (void)unregisterView {
    [self.richMedia removeFromSuperview];
    [self.gestures removeAllObjects];
}

#pragma mark - Trackers

- (void)registerTap {
    [STKSpinnerScreen show];
    __weak typeof(self) weakSelf = self;
    [STKProductPresentation openURLs:self.ad.clickThrough success:^(NSURL * productLink) {
        [STKThirdPartyEventTracker sendTrackingEvents:weakSelf.ad.clickTrackers];
        [weakSelf.delegate nativeAdAdapterTrackUserInteraction:weakSelf];
        [STKSpinnerScreen hide];
    } failure:^(NSError * error) {
        [STKSpinnerScreen hide];
    } completion:^{
    }];
}

- (void)nativeAdDidTrackViewability {
    [STKThirdPartyEventTracker sendTrackingEvents:self.ad.impressionTrackers];
}

- (void)nativeAdDidTrackFinish {
    //no-op
}

- (void)nativeAdDidTrackImpression {
    //no-op
}

#pragma mark - STKRichMediaPlayerViewDelegate

- (void)playerViewWillPresentFullscreen:(STKRichMediaPlayerView *)playerView {
    
}

- (void)playerViewDidDissmissFullscreen:(STKRichMediaPlayerView *)playerView {
    
}

- (void)playerViewWillShowProduct:(STKRichMediaPlayerView *)playerView {
    
}

- (void)playerViewDidInteract:(STKRichMediaPlayerView *)playerView {
    [STKThirdPartyEventTracker sendTrackingEvents:self.ad.clickTrackers];
    [self.delegate nativeAdAdapterTrackUserInteraction:self];
}

@end

@implementation BDMNASTRichMediaAsset

@dynamic track;

+ (instancetype)assetWithNastAd:(STKNASTAd *)nastAd {
    BDMNASTRichMediaAsset *_instance = [self assetWithInLine:nastAd.VASTInLineModel error:nil];
    if (!_instance) {
        _instance = BDMNASTRichMediaAsset.new;
    }
    _instance.placeholderImageURL = [NSURL URLWithString:nastAd.mainURLString];
    return _instance;
}

@end
