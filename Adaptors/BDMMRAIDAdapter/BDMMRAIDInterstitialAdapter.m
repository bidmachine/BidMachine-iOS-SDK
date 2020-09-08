//
//  BDMMRAIDInterstitialAdapter.m
//
//  Copyright © 2018 Appodeal. All rights reserved.
//

@import StackUIKit;
@import StackMRAIDKit;
@import StackFoundation;

#import "BDMMRAIDNetwork.h"
#import "BDMMRAIDInterstitialAdapter.h"


@interface BDMMRAIDInterstitialAdapter () <STKMRAIDAdDelegate, STKMRAIDServiceDelegate, STKMRAIDInterstitialPresenterDelegate, STKProductControllerDelegate>

@property (nonatomic, strong) STKMRAIDAd *ad;
@property (nonatomic, strong) STKProductController *productPresenter;
@property (nonatomic, strong) STKMRAIDInterstitialPresenter *presenter;
@property (nonatomic,   copy) NSDictionary<NSString *,NSString *> * contentInfo;

@property (nonatomic, assign) NSTimeInterval skipOffset;

@end

@implementation BDMMRAIDInterstitialAdapter

- (UIView *)adView {
    return self.ad.webView;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSArray *mraidFeatures      = @[kMRAIDSupportsInlineVideo, kMRAIDSupportsLoging, kMRAIDPreloadURL];

    self.adContent              = ANY(contentInfo).from(BDMMRAIDCreativeKey).string;
    self.contentInfo            = contentInfo;
    self.ad                     = [STKMRAIDAd new];
    self.ad.delegate            = self;
    self.ad.service.delegate    = self;
    self.presenter              = [STKMRAIDInterstitialPresenter new];
    self.presenter.delegate     = self;
    
    [self.ad.service.configuration registerServices:mraidFeatures];
    [self.ad loadHTML:self.adContent];
}

- (void)present {
    self.presenter.configuration = ({
        STKMRAIDPresentationConfiguration *configuration        = STKMRAIDPresentationConfiguration.new;
        configuration.closeInterval                             = ANY(self.contentInfo).from(BDMMRAIDSkipOffsetKey).number.floatValue;
        configuration.ignoreUseCustomClose                      = ANY(self.contentInfo).from(BDMMRAIDNativeCloseKey).number.boolValue; 
        configuration;
    });
    [self.presenter presentAd:self.ad];
}

- (STKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [STKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
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

#pragma mark - STKMRAIDInterstitialPresenterDelegate

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
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller willLeaveApplicationToProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    [STKSpinnerScreen hide];
}

@end
