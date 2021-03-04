//
//  BDMExternalAdapterRequestController.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 26.01.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMExternalAdapterConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

@class BDMExternalAdapterRequestController;

@protocol BDMExternalAdapterRequestControllerDelegate <NSObject>

- (void)controller:(BDMExternalAdapterRequestController *)controller didPrepareRequest:(BDMRequest *)request;

- (void)controller:(BDMExternalAdapterRequestController *)controller didFailPrepareRequest:(NSError *)error;

@end

@interface BDMExternalAdapterRequestController : NSObject

@property (nonatomic, assign) BOOL autoInitializeIfNeeded;

- (instancetype)initWithType:(BDMInternalPlacementType)type
                    delegate:(id<BDMExternalAdapterRequestControllerDelegate>)delegate;

- (void)prepareRequestWithConfiguration:(nullable BDMExternalAdapterConfiguration *)configuration;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
