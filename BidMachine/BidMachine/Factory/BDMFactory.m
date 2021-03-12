//
//  BDMFactory.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMFactory.h"
#import "BDMSdk.h"
#import "BDMRegistry.h"
#import "BDMHeaderBiddingInitialisationOperation.h"
#import "BDMHeaderBiddingPreparationOperation.h"


@implementation BDMFactory

+ (instancetype)sharedFactory {
    static BDMFactory * _sharedFactory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFactory = BDMFactory.new;
    });
    return _sharedFactory;
}

- (BDMSdk *)sharedSdk {
    return [BDMSdk sharedSdk];
}

- (BDMRegistry *)registry {
    return [BDMRegistry new];
}

- (BDMHeaderBiddingInitialisationOperation *)initialisationOperationForNetworks:(NSArray <BDMAdNetworkConfiguration *> *)networks
                                                                     controller:(BDMHeaderBiddingController *)controller
                                                              waitUntilFinished:(BOOL)waitUntilFinished {
    return [BDMHeaderBiddingInitialisationOperation initialisationOperationForNetworks:networks
                                                                            controller:controller
                                                                     waitUntilFinished:waitUntilFinished];
}

- (BDMHeaderBiddingPreparationOperation *)preparationOperationForNetworks:(NSArray<BDMAdNetworkConfiguration *> *)networks
                                                               controller:(BDMHeaderBiddingController *)controller
                                                                placement:(BDMPlacement *)placement {
    return [BDMHeaderBiddingPreparationOperation preparationOperationForNetworks:networks
                                                                      controller:controller
                                                                       placement:placement];
}

- (UIViewController *)topPresentedViewController {
    UIViewController * topController = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
