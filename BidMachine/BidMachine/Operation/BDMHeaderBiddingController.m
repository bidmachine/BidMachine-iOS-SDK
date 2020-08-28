//
//  BDMHeaderBiddingController.m
//  BidMachine
//
//  Created by Stas Kochkin on 24/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMHeaderBiddingController.h"
#import "BDMDefines.h"
#import "NSError+BDMSdk.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMHeaderBiddingController ()

@end


@implementation BDMHeaderBiddingController

- (void)initializeNetwork:(BDMAdNetworkConfiguration *)config
               completion:(void (^)(void))completion {
    id<BDMNetwork> network = [self.delegate networkWithName:config.name controller:self];
    [self.middleware startEvent:BDMEventHeaderBiddingNetworkInitializing
                        network:config.name];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [network initialiseWithParameters:config.initializationParams completion:^(BOOL hasAttempt, NSError *error) {
            if (!hasAttempt) {
                [weakSelf.middleware removeEvent:BDMEventHeaderBiddingNetworkInitializing
                                         network:config.name];
            } else if (error) {
                BDMLog(@"Header bidding network initialisation error: %@", error);
                [weakSelf.middleware rejectEvent:BDMEventHeaderBiddingNetworkInitializing
                                          network:config.name
                                            code:BDMErrorCodeHeaderBiddingNetwork];
            } else {
                [weakSelf.middleware fulfillEvent:BDMEventHeaderBiddingNetworkInitializing
                                          network:config.name];
            }
            
            STK_RUN_BLOCK(completion);
        }];
    });
}

- (void)prepareAdUnit:(BDMAdUnit *)adUnit
            placement:(BDMInternalPlacementType)placement
              network:(NSString *)network
           completion:(void (^)(id<BDMPlacementAdUnit>))completion {
    id<BDMNetwork> adNetwork = [self.delegate networkWithName:network controller:self];
    NSString *ver = [adNetwork sdkVersion];
    [self.middleware startEvent:BDMEventHeaderBiddingNetworkPreparing
                      placement:placement
                        network:network];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [adNetwork collectHeaderBiddingParameters:adUnit.customParams
                                     adUnitFormat:adUnit.format
                                       completion:^(NSDictionary<NSString *,id> *bidding, NSError *error) {
            if (error || !bidding.count) {
                [weakSelf.middleware rejectEvent:BDMEventHeaderBiddingNetworkPreparing
                                       placement:placement
                                         network:network
                                            code:BDMErrorCodeHeaderBiddingNetwork];
            } else {
                [weakSelf.middleware fulfillEvent:BDMEventHeaderBiddingNetworkPreparing
                                        placement:placement
                                          network:network];
            }
            
            if (bidding.count) {
                // Merge bidding info into object
                id<BDMPlacementAdUnit> placementUnit = [BDMPlacementAdUnitBuilder placementAdUnitWithBuild:^(BDMPlacementAdUnitBuilder *builder) {
                    builder.appendAdUnit(adUnit);
                    builder.appendBidder(network);
                    builder.appendSdkVersion(ver);
                    builder.appendClientParamters(bidding);
                }];
                STK_RUN_BLOCK(completion, placementUnit);
            } else {
                STK_RUN_BLOCK(completion, nil);
            }
        }];
    });
}

- (void)invalidateAdUnit:(BDMAdUnit *)adUnit
               placement:(BDMInternalPlacementType)placement
                 network:(NSString *)network {
    [self.middleware rejectEvent:BDMEventHeaderBiddingNetworkPreparing
                       placement:placement
                         network:network
                            code:BDMErrorCodeTimeout];
}

@end
