//
//  BDMNASTNativeServiceAdapter.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

@import StackNASTKit;

#import "BDMNASTNetwork.h"
#import "BDMNASTDisplayAdapter.h"
#import "BDMNASTNativeAdServiceAdapter.h"

@implementation BDMNASTNativeAdServiceAdapter

- (UIView *)adView {
    return nil;
}

- (void)prepareContent:(NSDictionary<NSString *,NSString *> *)contentInfo {
     __weak typeof(self) weakSelf = self;
    STKNASTManager *manager = STKNASTManager.new;
    [manager parseAdFromJSON:contentInfo completion:^(STKNASTAd * ad, NSError * error) {
        if (error) {
            [weakSelf.loadingDelegate adapter:weakSelf failedToPrepareContentWithError: [error bdm_wrappedWithCode:BDMErrorCodeNoContent]];
        } else {
            BDMNASTDisplayAdapter * adapter = [BDMNASTDisplayAdapter displayAdapterForAd:ad contentInfo:contentInfo];
            [weakSelf.loadingDelegate service:weakSelf didLoadNativeAds:@[adapter]];
        }
    }];
}

@end
