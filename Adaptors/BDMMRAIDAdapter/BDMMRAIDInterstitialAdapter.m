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

@property (nonatomic, assign) BOOL shouldCache;
@property (nonatomic, assign) NSTimeInterval closableViewDelay;
@property (nonatomic, copy) NSString *adContent;

@end

@implementation BDMMRAIDInterstitialAdapter

- (UIView *)adView {
    return self.ad.webView;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    self.adContent          = contentInfo[@"creative"];
    self.shouldCache        = contentInfo[@"should_cache"] ? [contentInfo[@"should_cache"] boolValue] : YES;
    self.closableViewDelay  = contentInfo[@"closable_view_delay"] ? [contentInfo[@"closable_view_delay"] floatValue] : 10.0f;
    
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
    
    if (self.shouldCache) {
        [self.ad loadHTML:self.adContent];
    } else {
        [self.loadingDelegate adapterPreparedContent:self];
    }
}

- (void)present {
    if (self.shouldCache) {
        [self.presenter presentAd:self.ad];
    } else {
        self.activityWindow = [[STKSpinnerWindow alloc] initWithBlur:YES];
        __weak typeof(self) weakSelf = self;
        BDMMRAIDClosableView *closableView = [BDMMRAIDClosableView closableView:self.closableViewDelay action:^(BDMMRAIDClosableView *closableView) {
            [weakSelf hideActivityWindow];
            NSError *error = NSError.bdm_error(@"User skip interstitial");
            [weakSelf.displayDelegate adapter:weakSelf failedToPresentAdWithError:error];
        }];
        self.activityWindow.hidden = NO;
        [closableView render:self.activityWindow];
        [self.ad loadHTML:self.adContent];
    }
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
    if (self.shouldCache) {
        [self.loadingDelegate adapterPreparedContent:self];
    } else {
        [self hideActivityWindow];
        [self.presenter presentAd:ad];
    }
}

- (void)didFailToLoadAd:(STKMRAIDAd *)ad withError:(NSError *)error {
    if (self.shouldCache) {
        [self.loadingDelegate adapter:self failedToPrepareContentWithError:error];
    } else {
        [self hideActivityWindow];
        [self.displayDelegate adapter:self failedToPresentAdWithError:error];
    }
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
