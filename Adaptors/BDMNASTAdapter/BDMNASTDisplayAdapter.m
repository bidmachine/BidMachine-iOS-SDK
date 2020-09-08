//
//  BDMNASTDisplayAdapter.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

@import StackUIKit;
@import StackFoundation;

#import "BDMNASTEventReducer.h"
#import "BDMNASTDisplayAdapter.h"
#import "BDMNASTMediaController.h"
#import "BDMNASTActionController.h"


@interface BDMNASTDisplayAdapter ()<BDMNASTEventReducerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) STKNASTAd *ad;
@property (nonatomic, strong) BDMNASTEventReducer *reducer;
@property (nonatomic, strong) BDMNASTMediaController *mediaController;
@property (nonatomic, strong) BDMNASTActionController *actionController;

@end

@implementation BDMNASTDisplayAdapter

+ (instancetype)displayAdapterForAd:(STKNASTAd *)ad contentInfo:(NSDictionary<NSString *,NSString *> *)contentInfo {
    return [[self alloc] initWithNativeAd:ad contentInfo:contentInfo];
}

- (instancetype)initWithNativeAd:(STKNASTAd *)ad contentInfo:(NSDictionary<NSString *,NSString *> *)contentInfo {
    if (self = [super init]) {
        BDMNASTEventReducer *reducer    = [[BDMNASTEventReducer alloc] initWithAd:ad delegate:self];

        self.mediaController            = [[BDMNASTMediaController alloc] initWithAd:ad];
        self.actionController           = [[BDMNASTActionController alloc] initWithAd:ad info:contentInfo];
        
        self.ad                         = ad;
        self.reducer                    = reducer;
        self.mediaController.reducer    = reducer;
        self.actionController.reducer   = reducer;
    }
    return self;
}

#pragma mark - LifeCicle

- (void)invalidate {
    [self unregisterView];
}

- (void)unregisterView {
    [self.actionController invalidate];
    [self.mediaController invalidate];
}

#pragma mark - Event Tracker

- (void)nativeAdDidTrackViewability {
    [self.reducer trackImpression];
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
    return self.mediaController.video;
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
        [self.mediaController renderInContainer:adRendering.mediaContainerView controller:controller];
    }
    
    NSMutableSet *viewSet = NSMutableSet.set;
    [viewSet addObjectsFromArray:clickableViews?: @[]];
    [viewSet addObject:adRendering.titleLabel];
    [viewSet addObject:adRendering.callToActionLabel];
    
    [self.actionController registerClickableViews:viewSet.allObjects];
}

#pragma mark - BDMNASTEventReducerDelegate

- (void)eventReducerTrackAction:(BDMNASTEventReducer *)reducer {
    [self.delegate nativeAdAdapterTrackUserInteraction:self];
}

@end
