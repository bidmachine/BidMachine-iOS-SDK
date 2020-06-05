//
//  BDMMRAIDBannerAdapter.m
//  BDMMRAIDBannerAdapter
//
//  Created by Pavel Dunyashev on 11/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMMRAIDBannerAdapter.h"
#import "BDMMRAIDNetwork.h"
#import "BDMMRAIDClosableView.h"
#import "NSError+BDMMRAIDAdapter.h"
#import <BidMachine/NSError+BDMSdk.h>

@import StackUIKit;
@import StackFoundation;
@import StackMRAIDKit;


const CGSize kBDMAdSize320x50  = {.width = 320.0f, .height = 50.0f  };
const CGSize kBDMAdSize728x90  = {.width = 728.0f, .height = 90.0f  };


@interface BDMMRAIDBannerAdapter () <STKMRAIDAdDelegate, STKMRAIDServiceDelegate, STKMRAIDViewPresenterDelegate, STKProductControllerDelegate>

@property (nonatomic, strong) STKMRAIDAd *ad;
@property (nonatomic, strong) STKMRAIDViewPresenter *presenter;

@property (nonatomic, strong) STKProductController *productPresenter;
@property (nonatomic, strong) STKSpinnerView *activityIndicatorView;

@property (nonatomic, weak) UIView *container;

@end

@implementation BDMMRAIDBannerAdapter

- (UIView *)adView {
    return self.presenter;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    self.adContent          = contentInfo[@"creative"];
    
    CGSize bannerSize       = [self sizeFromContentInfo:contentInfo];
    CGRect frame            = (CGRect){.size = bannerSize};
    
    NSArray *mraidFeatures  = @[
                                kMRAIDSupportsInlineVideo,
                                kMRAIDSupportsLoging
                                ];
    self.ad = [STKMRAIDAd new];
    self.ad.delegate = self;
    self.ad.service.delegate = self;
    [self.ad.service.configuration registerServices:mraidFeatures];
    
    self.presenter = [STKMRAIDViewPresenter new];
    self.presenter.delegate = self;
    self.presenter.frame = frame;
    [self.ad loadHTML:self.adContent];
}

- (void)presentInContainer:(UIView *)container {
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.container = container;
    [container addSubview:self.presenter];
    [self.presenter presentAd:self.ad];
}

#pragma mark - AMKAdDelegate

- (void)didLoadAd:(STKMRAIDAd *)ad {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)didFailToLoadAd:(STKMRAIDAd *)ad withError:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
}

- (void)didUserInteractionAd:(STKMRAIDAd *)ad withURL:(NSURL *)url {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    NSArray <NSURL *> *urls = url ? @[url] : @[];
    [STKSpinnerScreen show];
    [self.productPresenter presentUrls:urls];
}

#pragma mark - AMKWebServiceDelegate

- (void)mraidServiceDidReceiveLogMessage:(NSString *)message {
    BDMLog(@"%@", message);
}

- (void)mraidServicePreloadProductUrl:(NSURL *)url {
    NSArray <NSURL *> *urls = url ? @[url] : @[];
    [self.productPresenter prepareUrls:urls];
}

#pragma mark - ASKProductControllerDelegate

- (UIViewController *)presenterRootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.stk_topPresentedViewController;
}

- (void)controller:(STKProductController *)controller didDismissProduct:(NSURL *)productURL {
    [self.displayDelegate adapterDidDismissScreen:self];
}

- (void)controller:(STKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller willLeaveApplicationToProduct:(NSURL *)productURL {
    [STKSpinnerScreen hide];
    [self.displayDelegate adapterWillLeaveApplication:self];
}

- (void)controller:(STKProductController *)controller willPresentProduct:(NSURL *)productURL {
    [STKSpinnerScreen hide];
    [self.displayDelegate adapterWillPresentScreen:self];
}

- (void)controller:(nonnull STKProductController *)controller didPreloadProduct:(nonnull NSURL *)productURL {}

- (void)controllerDidCompleteProcessing:(nonnull STKProductController *)controller {}


#pragma mark - Private

- (CGSize)sizeFromContentInfo:(NSDictionary *)contentInfo {
    NSNumber * width = contentInfo[@"width"] ? : contentInfo[@"w"];
    NSNumber * height = contentInfo[@"height"] ? : contentInfo[@"h"];
    if (ANY(width).number == nil || ANY(height).number == nil) {
        return [self defaultAdSize];
    }
    if (width.floatValue <= 0 ||
        height.floatValue <= 0) {
        return [self defaultAdSize];
    }
    
    return CGSizeMake(width.floatValue,
                      height.floatValue);
}

- (STKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [STKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
}

- (CGSize)defaultAdSize {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kBDMAdSize728x90 : kBDMAdSize320x50;
}

@end
