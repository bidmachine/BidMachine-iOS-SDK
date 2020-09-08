//
//  BDMNASTActionController.m
//  BDMNASTAdapter
//
//  Created by Ilia Lozhkin on 08.09.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

@import StackUIKit;
@import StackFoundation;

#import "BDMNASTActionController.h"


@interface BDMNASTActionController ()<STKProductControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic,   copy) NSArray<NSURL *> *clicks;
@property (nonatomic,   copy) NSDictionary<NSString *,NSString *> *info;
@property (nonatomic, strong) STKProductController *productPresenter;
@property (nonatomic, strong) NSMutableArray<UITapGestureRecognizer *> *gestures;

@end

@implementation BDMNASTActionController

- (instancetype)initWithAd:(STKNASTAd *)ad info:(NSDictionary<NSString *,NSString *> *)info {
    if (self = [super init]) {
        _info       = info;
        _clicks     = ad.clickThrough;
        _gestures   = NSMutableArray.new;
    }
    return self;
}

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews {
    [self invalidate];
    [clickableViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * stop) {
        UITapGestureRecognizer *gesture = [self tapGestureRecognizer];
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:gesture];
        [self.gestures addObject:gesture];
    }];
}

- (void)invalidate {
    [self.gestures removeAllObjects];
}

#pragma mark - Action

- (void)userInteraction {
    [STKSpinnerScreen show];
    [self.productPresenter presentProductWithParameters:self.productParameters(self.clicks)];
}

#pragma mark - Private

- (STKProductController *)productPresenter {
    if (!_productPresenter) {
        _productPresenter = [STKProductController new];
        _productPresenter.delegate = self;
    }
    return _productPresenter;
}

- (NSDictionary *(^)(NSArray<NSURL *>*))productParameters {
    return ^NSDictionary *(NSArray<NSURL *> *urls){
        NSMutableDictionary *productParameters = self.info.mutableCopy;
        productParameters[STKProductParameterClickThrough] = urls;
        return productParameters.copy;
    };
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInteraction)];
    gesture.numberOfTouchesRequired = 1;
    return gesture;
}

#pragma mark - STKProductControllerDelegate

- (void)controller:(STKProductController *)controller didFailToPresentWithError:(NSError *)error {
    [STKSpinnerScreen hide];
}

- (void)controller:(STKProductController *)controller willPresentProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
    [STKSpinnerScreen hide];
    [self.eventController trackAction];
}

- (void)controller:(STKProductController *)controller willLeaveApplicationToProductWithParameters:(NSDictionary <NSString *, id> *)parameters {
    [STKSpinnerScreen hide];
    [self.eventController trackAction];
}

@end
