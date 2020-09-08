//
//  BDMVASTVideoAdapter.m
//  BDMVASTVideoAdapter
//
//  Created by Pavel Dunyashev on 24/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

@import StackUIKit;
@import StackVASTKit;
@import StackFoundation;
@import BidMachine.Adapters;

#import "BDMVASTNetwork.h"
#import "BDMVASTVideoAdapter.h"


@interface BDMVASTVideoConfiguration : NSObject

@property (nonatomic, assign) BOOL useNativeClose;
@property (nonatomic, assign) NSTimeInterval maxDuration;
@property (nonatomic, assign) NSTimeInterval videoSkipOffset;
@property (nonatomic, assign) NSTimeInterval companionSkipOffset;

@end

@implementation BDMVASTVideoConfiguration

- (NSTimeInterval)maxDuration {
    return _maxDuration > 0 ? _maxDuration : 180;
}

@end

@interface BDMVASTVideoAdapter () <STKVASTControllerDelegate, STKProductControllerDelegate>

@property (nonatomic, strong) STKVASTController *videoController;
@property (nonatomic, strong) STKProductController *productPresenter;
@property (nonatomic, strong) BDMVASTVideoConfiguration *configuration;
@property (nonatomic,   copy) NSDictionary<NSString *,NSString *> * contentInfo;

@end

@implementation BDMVASTVideoAdapter

- (UIView *)adView {
    return self.videoController.view;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
    NSString *rawXML        = ANY(contentInfo).from(BDMVASTCreativeKey).string;
    NSData *xmlData         = [rawXML dataUsingEncoding:NSUTF8StringEncoding];
    
    self.configuration      = [self configurationFrom:contentInfo];
    self.videoController    = [STKVASTController new];
    self.contentInfo        = contentInfo;
    
    [self.videoController setDelegate:self];
    [self.videoController loadForVastXML:xmlData];
}

- (void)present {
    [self.videoController presentFromViewController:self.rootViewController];
}

#pragma mark - Private

- (STKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [STKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
}

- (BDMVASTVideoConfiguration *)configurationFrom:(NSDictionary<NSString *,NSString *> *)contentInfo {
    BDMVASTVideoConfiguration *configuration    = BDMVASTVideoConfiguration.new;
    configuration.maxDuration                   = ANY(contentInfo).from(BDMVASTMaxDurationKey).number.doubleValue;
    configuration.useNativeClose                = ANY(contentInfo).from(BDMVASTUseNativeCloseKey).number.boolValue;
    configuration.videoSkipOffset               = ANY(contentInfo).from(BDMVASTVideoSkipOffsetKey).number.doubleValue;
    configuration.companionSkipOffset           = ANY(contentInfo).from(BDMVASTCompanionSkipOffsetKey).number.doubleValue;
    return configuration;
}

- (NSDictionary *(^)(NSString *))productParameters {
    return ^NSDictionary *(NSString *url){
        NSMutableDictionary *productParameters = self.contentInfo.mutableCopy;
        productParameters[STKProductParameterClickThrough] = url;
        return productParameters.copy;
    };
}

#pragma mark - STKVASTControllerDelegate

- (void)vastControllerReady:(STKVASTController *)controller {
    [self.loadingDelegate adapterPreparedContent:self];
}

- (void)vastController:(STKVASTController *)controller didFailToLoad:(NSError *)error {
    [self.loadingDelegate adapter:self failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
}

- (void)vastController:(STKVASTController *)controller didFailWhileShow:(NSError *)error {
    [self.displayDelegate adapter:self failedToPresentAdWithError: [error bdm_wrappedWithCode:BDMErrorCodeBadContent]];
}

- (void)vastControllerDidClick:(STKVASTController *)controller clickURL:(NSString *)clickURL {
    [STKSpinnerScreen show];
    [self.productPresenter presentProductWithParameters:self.productParameters(clickURL)];
}

- (void)vastControllerDidDismiss:(STKVASTController *)controller {
    [self.displayDelegate adapterDidDismiss:self];
}

- (void)vastControllerDidFinish:(STKVASTController *)controller {
    [self.displayDelegate adapterFinishRewardAction:self];
}

- (void)vastControllerDidPresent:(STKVASTController *)controller {
    [self.displayDelegate adapterWillPresent:self];
}

- (void)vastControllerDidSkip:(STKVASTController *)controller {
    // NO-OP
}

#pragma mark - STKVASTControllerDelegate parameters

- (NSNumber *)closeTime {
    return @(self.configuration.companionSkipOffset);
}

- (BOOL)forceCloseTime {
    return self.configuration.useNativeClose;
}

- (NSNumber *)videoCloseTime {
    return @(self.configuration.videoSkipOffset);
}

- (NSNumber *)maxDuration {
    return @(self.configuration.maxDuration);
}

- (BOOL)isAutoclose {
    return NO;
}

- (BOOL)isRewarded {
    return self.rewarded;
}

- (UIViewController *)rootViewController {
    return [self.displayDelegate rootViewControllerForAdapter:self] ?: UIViewController.stk_topPresentedViewController;
}

#pragma mark - STKProductControllerDelegate

- (void)controller:(STKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller willLeaveApplicationToProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller willPresentProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
    [self.displayDelegate adapterRegisterUserInteraction:self];
    [self.videoController pause];
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller didDismissProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
     [self.videoController resume];
}

@end
