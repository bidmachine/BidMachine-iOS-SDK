//
//  BDMMRAIDInterstitialAdapter.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

#define DEFAULT_SKIP_INTERVAL 3

#import "BDMMRAIDInterstitialAdapter.h"
#import "BDMMRAIDNetwork.h"
#import "NSError+BDMMRAIDAdapter.h"
#import "BDMMRAIDClosableView.h"
#import <BidMachine/NSError+BDMSdk.h>


@import StackUIKit;
@import StackMRAIDKit;


@interface BDMMRAIDInterstitialAdapter () <STKMRAIDAdDelegate, STKMRAIDServiceDelegate, STKMRAIDInterstitialPresenterDelegate, STKProductControllerDelegate>

@property (nonatomic, strong) STKMRAIDAd *ad;
@property (nonatomic, strong) STKMRAIDInterstitialPresenter *presenter;

@property (nonatomic, strong) STKProductController *productPresenter;
@property (nonatomic, strong) STKSpinnerWindow *activityWindow;

@property (nonatomic, strong) STKMRAIDPresentationConfiguration *configuration;
@property (nonatomic, assign) NSTimeInterval skipOffset;
@property (nonatomic, copy) NSString *adContent;

@end

@implementation BDMMRAIDInterstitialAdapter

- (UIView *)adView {
    return self.ad.webView;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    self.adContent          = contentInfo[@"creative"];
    self.configuration      = STKMRAIDPresentationConfiguration.new;
    self.configuration.closeInterval = [contentInfo[@"skip_offset"] floatValue];
    self.configuration.ignoreUseCustomClose = [contentInfo[@"use_native_close"] boolValue];
    
    NSArray *mraidFeatures  = @[
                                kMRAIDSupportsInlineVideo,
                                kMRAIDSupportsLoging,
                                kMRAIDPreloadURL
                                ];
    
    self.ad = [STKMRAIDAd new];
    self.ad.delegate = self;
    self.ad.service.delegate = self;
    [self.ad.service.configuration registerServices:mraidFeatures];
    
    self.presenter = [STKMRAIDInterstitialPresenter new];
    self.presenter.delegate = self;
    [self.ad loadHTML:self.adContent];
}

- (void)present {
    self.presenter.configuration = self.configuration;
    [self.presenter presentAd:self.ad];
}

- (void)hideActivityWindow {
    self.activityWindow.hidden = YES;
    self.activityWindow = nil;
}

- (STKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [STKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
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

#pragma mark - AMKInterstitialPresenterDelegate

- (void)presenterDidAppear:(id<STKMRAIDPresenter>)presenter {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)presenterDidDisappear:(id<STKMRAIDPresenter>)presenter {
    if (self.rewarded) {
        [self.displayDelegate adapterFinishRewardAction:self];
    }
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)presenterFailToPresent:(id<STKMRAIDPresenter>)presenter withError:(NSError *)error {
    NSError *wrappedError = [error bdm_wrappedWithCode:BDMErrorCodeBadContent];
    [self.displayDelegate adapter:self failedToPresentAdWithError:wrappedError];
}

#pragma mark - STKProductControllerDelegate

- (UIViewController *)presenterRootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.stk_topPresentedViewController;
}

- (void)controller:(STKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller willLeaveApplicationToProduct:(NSURL *)productURL {
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller willPresentProduct:(NSURL *)productURL {
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller didDismissProduct:(NSURL *)productURL {}

- (void)controller:(nonnull STKProductController *)controller didPreloadProduct:(nonnull NSURL *)productURL {}

- (void)controllerDidCompleteProcessing:(nonnull STKProductController *)controller {}

@end
