//
//  BDMNASTDisplayAdapter.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMNASTDisplayAdapter.h"
#import <StackUIKit/StackUIKit.h>


@interface BDMNASTDisplayAdapter ()

@property (nonatomic, strong) STKNASTAd *ad;
@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;

@end

@implementation BDMNASTDisplayAdapter

+ (instancetype)displayAdapterForAd:(STKNASTAd *)ad {
    return [[self alloc] initWithNativeAd:ad];
}

- (instancetype)initWithNativeAd:(STKNASTAd *)ad {
    if (self = [super init]) {
        self.ad = ad;
    }
    return self;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerTap)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _tapGestureRecognizer;
}

#pragma mark - BDMNativeAd

- (void)renderOn:(id<BDMNativeAdRendering>)adRendering
        delegate:(id<BDMNativeAdAdapterDelegate>)delegate
      dataSource:(id<BDMNativeAdAdapterDataSource>)dataSource
{
    adRendering.titleLabel.text = self.ad.title;
    adRendering.callToActionLabel.text = self.ad.callToAction;
    
    if ([adRendering respondsToSelector:@selector(descriptionLabel)]) {
        adRendering.descriptionLabel.text = self.ad.descriptionText;
    }
    
    if ([adRendering respondsToSelector:@selector(iconView)]) {
        adRendering.iconView.stkFastImageCache([NSURL URLWithString:self.ad.iconURLString]);
    }
    
    if ([adRendering respondsToSelector:@selector(mediaContainerView)]) {
#warning Implement RachMedia
    }
    
    // Clicks
    NSArray *clickableViews = @[adRendering.callToActionLabel, adRendering.containerView];
    [clickableViews enumerateObjectsUsingBlock:^(UIView * view, NSUInteger idx, BOOL * stop) {
        [view addGestureRecognizer:self.tapGestureRecognizer];
    }];
}

#pragma mark - Trackers

- (void)registerTap {
    
}

- (void)nativeAdDidTrackFinish {
    
}

- (void)nativeAdDidTrackImpression {
    
}

- (void)nativeAdDidTrackViewability {
    
}

@end
