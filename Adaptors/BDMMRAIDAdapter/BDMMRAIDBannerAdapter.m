//
//  BDMMRAIDBannerAdapter.m
//  BDMMRAIDBannerAdapter
//
//  Created by Pavel Dunyashev on 11/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

@import StackUIKit;
@import StackMRAIDKit;
@import StackFoundation;

#import "BDMMRAIDNetwork.h"
#import "BDMMRAIDBannerAdapter.h"


const CGSize kBDMAdSize320x50  = {.width = 320.0f, .height = 50.0f  };
const CGSize kBDMAdSize728x90  = {.width = 728.0f, .height = 90.0f  };

@interface BDMMRAIDBannerAdapter () <STKMRAIDAdDelegate, STKMRAIDServiceDelegate, STKMRAIDViewPresenterDelegate, STKProductControllerDelegate>

@property (nonatomic, strong) STKMRAIDAd *ad;
@property (nonatomic, strong) STKMRAIDViewPresenter *presenter;
@property (nonatomic, strong) STKProductController *productPresenter;
@property (nonatomic,   copy) NSDictionary<NSString *,NSString *> * contentInfo;

@property (nonatomic,   weak) UIView *container;

@end

@implementation BDMMRAIDBannerAdapter

- (UIView *)adView {
    return self.presenter;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    CGSize bannerSize               = [self sizeFromContentInfo:contentInfo];
    CGRect frame                    = (CGRect){.size = bannerSize};
    NSArray *mraidFeatures          = @[kMRAIDSupportsInlineVideo, kMRAIDSupportsLoging];
    
    self.adContent                  = ANY(contentInfo).from(BDMMRAIDCreativeKey).string;
    self.contentInfo                = contentInfo;
    self.ad                         = [STKMRAIDAd new];
    self.ad.delegate                = self;
    self.ad.service.delegate        = self;
    self.presenter                  = [STKMRAIDViewPresenter new];
    self.presenter.delegate         = self;
    self.presenter.frame            = frame;
    
    [self.ad.service.configuration registerServices:mraidFeatures];
    [self.ad loadHTML:self.adContent];
}

- (void)presentInContainer:(UIView *)container {
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [container addSubview:self.presenter];
    [self.presenter presentAd:self.ad];
    self.container = container;
}

#pragma mark - Private

- (STKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [STKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
}

- (CGSize)sizeFromContentInfo:(NSDictionary *)contentInfo {
    NSNumber *width     = contentInfo[@"width"]  ? : contentInfo[@"w"];
    NSNumber *height    = contentInfo[@"height"] ? : contentInfo[@"h"];
    
    if (ANY(width).number <= 0 || ANY(height).number <= 0) {
        return [self defaultAdSize];
    }
    
    return CGSizeMake(width.floatValue, height.floatValue);
}

- (CGSize)defaultAdSize {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kBDMAdSize728x90 : kBDMAdSize320x50;
}

- (NSDictionary *(^)(NSURL *))productParameters {
    return ^NSDictionary *(NSURL *url){
        NSMutableDictionary *productParameters = self.contentInfo.mutableCopy;
        productParameters[STKProductParameterClickThrough] = url;
        return productParameters.copy;
    };
}

#pragma mark - STKMRAIDAdDelegate

- (void)didLoadAd:(STKMRAIDAd *)ad {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)didFailToLoadAd:(STKMRAIDAd *)ad withError:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)didUserInteractionAd:(STKMRAIDAd *)ad withURL:(NSURL *)url {
    [STKSpinnerScreen show];
    [self.productPresenter presentProductWithParameters:self.productParameters(url)];
}

- (UIViewController *)presenterRootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.stk_topPresentedViewController;
}

#pragma mark - STKMRAIDServiceDelegate

- (void)mraidServiceDidReceiveLogMessage:(NSString *)message {
    BDMLog(@"%@", message);
}

- (void)mraidServicePreloadProductUrl:(NSURL *)url {
    [self.productPresenter loadProductWithParameters:self.productParameters(url)];
}

#pragma mark - STKProductControllerDelegate

- (void)controller:(STKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller willPresentProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    [self.displayDelegate adapterWillPresentScreen:self];
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller didDismissProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
     [self.displayDelegate adapterDidDismissScreen:self];
}

- (void)controller:(STKProductController *)controller willLeaveApplicationToProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    [self.displayDelegate adapterWillLeaveApplication:self];
    [STKSpinnerScreen hide];
    
}

@end
