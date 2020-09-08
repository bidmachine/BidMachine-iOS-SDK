//
//  BDMNASTMediaController.m
//  BDMNASTAdapter
//
//  Created by Ilia Lozhkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import StackUIKit;
@import StackRichMedia;

#import "BDMNASTMediaController.h"


@interface BDMNASTRichMediaAsset : STKVASTAsset <STKRichMediaAsset>

@property (nonatomic, copy) NSURL *placeholderImageURL;

+ (instancetype)assetWithNastAd:(STKNASTAd *)nastAd;

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

@interface BDMNASTMediaController () <STKRichMediaPlayerViewDelegate>

@property (nonatomic, strong) BDMNASTRichMediaAsset *asset;
@property (nonatomic, strong) STKRichMediaPlayerView *richMedia;

@end

@implementation BDMNASTMediaController

- (instancetype)initWithAd:(STKNASTAd *)ad {
    if (self = [super init]) {
        _asset = [BDMNASTRichMediaAsset assetWithNastAd:ad];
    }
    return self;
}

- (BOOL)video {
    return self.asset.contentURL != nil;
}

- (void)renderInContainer:(UIView *)container controller:(UIViewController *)controller {
    [self invalidate];
    [self.richMedia setRootViewController:controller];
    [self.richMedia stk_edgesEqual:container];
    [self.richMedia playAsset:self.asset];
}

- (void)invalidate {
    [self.richMedia removeFromSuperview];
}

#pragma mark - Private

- (STKRichMediaPlayerView *)richMedia {
    if (!_richMedia) {
        _richMedia = STKRichMediaPlayerView.new;
        _richMedia.delegate = self;
    }
    return _richMedia;
}

#pragma mark - STKRichMediaPlayerViewDelegate

- (void)playerViewWillPresentFullscreen:(STKRichMediaPlayerView *)playerView {
    
}

- (void)playerViewDidDissmissFullscreen:(STKRichMediaPlayerView *)playerView {
    
}

- (void)playerViewWillShowProduct:(STKRichMediaPlayerView *)playerView {
    
}

- (void)playerViewDidInteract:(STKRichMediaPlayerView *)playerView {
    [self.eventController trackAction];
}

@end
