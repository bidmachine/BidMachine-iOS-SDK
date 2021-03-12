//
//  BDMFactory.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BDMDefines.h"
#import "BDMPlacement.h"
#import "BDMHeaderBiddingController.h"


@class BDMSdk;
@class BDMRegistry;
@class BDMHeaderBiddingInitialisationOperation;
@class BDMHeaderBiddingPreparationOperation;
@class BDMAdNetworkConfiguration;
@protocol BDMPlacementAdUnit;


@interface BDMFactory : NSObject

@property (nonatomic, readonly) UIViewController *topPresentedViewController;
@property (nonatomic, readonly) BDMSdk *sharedSdk;
@property (nonatomic, readonly) BDMRegistry *registry;

+ (instancetype)sharedFactory;

- (BDMHeaderBiddingInitialisationOperation *)initialisationOperationForNetworks:(NSArray <BDMAdNetworkConfiguration *> *)networks
                                                                     controller:(BDMHeaderBiddingController *)controller
                                                              waitUntilFinished:(BOOL)waitUntilFinished;

- (BDMHeaderBiddingPreparationOperation *)preparationOperationForNetworks:(NSArray <BDMAdNetworkConfiguration *> *)networks
                                                               controller:(BDMHeaderBiddingController *)controller
                                                                placement:(BDMPlacement *)placement;

@end
