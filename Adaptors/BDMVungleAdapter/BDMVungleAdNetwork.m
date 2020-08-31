//
//  BDMVungleAdapter.m
//  BDMVungleAdapter
//
//  Created by Stas Kochkin on 19/07/2019.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import <StackFoundation/StackFoundation.h>
#import <VungleSDK/VungleSDKHeaderBidding.h>

#import "BDMVungleAdNetwork.h"
#import "BDMVungleValueTransformer.h"
#import "BDMVungleFullscreenAdapter.h"


@interface BDMVungleAdNetwork () <VungleSDKDelegate, VungleSDKHeaderBidding>

typedef void(^VungleHeaderBiddingCompletion)(NSDictionary<NSString *,id> *, NSError *);

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) void(^initialisationCompletion)(BOOL, NSError *);
@property (nonatomic, copy) NSMapTable <NSString *, VungleHeaderBiddingCompletion> *completionByPlacement;
@property (nonatomic, copy) NSHashTable <BDMVungleFullscreenAdapter *> *delegates;

@end


@implementation BDMVungleAdNetwork

- (NSString *)name {
    return @"vungle";
}

- (NSString *)sdkVersion {
    return VungleSDKVersion;
}

- (NSMapTable<NSString *,VungleHeaderBiddingCompletion> *)completionByPlacement {
    if (!_completionByPlacement) {
        _completionByPlacement = [NSMapTable strongToStrongObjectsMapTable];
    }
    return _completionByPlacement;
}

- (NSHashTable<BDMVungleFullscreenAdapter *> *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

- (void)initialiseWithParameters:(NSDictionary<NSString *,id> *)parameters
                      completion:(void (^)(BOOL, NSError *))completion {
    [self syncMetadata];
    if ([VungleSDK.sharedSDK isInitialized]) {
        STK_RUN_BLOCK(completion, NO, nil);
        return;
    }
    
    NSError *error = nil;
    NSString *appId = [BDMVungleValueTransformer.new transformedValue:parameters[@"app_id"]];
    
    if (appId) {
        self.appId = appId;
        VungleSDK.sharedSDK.delegate = self;
        VungleSDK.sharedSDK.headerBiddingDelegate = self;
        self.initialisationCompletion = completion;
        [VungleSDK.sharedSDK startWithAppId:appId error:&error];
    } else {
        error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"Vungle app id is not valid string"];
    }
    
    if (error) {
        self.initialisationCompletion = nil;
        BDMLog(@"Vungle initialisation failed with error: %@", error);
        STK_RUN_BLOCK(completion, YES, error);
    }
}

- (void)collectHeaderBiddingParameters:(NSDictionary<NSString *,id> *)parameters
                          adUnitFormat:(BDMAdUnitFormat)adUnitFormat
                            completion:(void (^)(NSDictionary<NSString *,id> *, NSError *))completion {
    NSString *placement = [BDMVungleValueTransformer.new transformedValue:parameters[@"placement_id"]];
    
    if (!placement) {
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeInternal description:@"Vungle placement id is not valid string"];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    
    NSString *token = [VungleSDK.sharedSDK bidTokenForPlacement:placement];
    if (token) {
        NSDictionary *bidding = @{ @"placement_id": placement, @"token": token };
        STK_RUN_BLOCK(completion, bidding, nil);
        return;
    }
    
    if ([VungleSDK.sharedSDK isAdCachedForPlacementID:placement]) {
        NSString *description = [NSString stringWithFormat:@"Vungle bid token is not available for placement %@", placement];
        NSError *error = [NSError bdm_errorWithCode:BDMErrorCodeInternal
                                        description:description];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    
    NSError *error = nil;
    [VungleSDK.sharedSDK loadPlacementWithID:placement error: &error];
    if (error) {
        error = [error bdm_wrappedWithCode:BDMErrorCodeUnknown];
        STK_RUN_BLOCK(completion, nil, error);
        return;
    }
    [self.completionByPlacement setObject:completion forKey:placement];
}

- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk {
    BDMVungleFullscreenAdapter *adapter = [BDMVungleFullscreenAdapter new];
    [self.delegates addObject:adapter];
    return adapter;
}

#pragma mark - VungleSDKDelegate

- (void)vungleSDKDidInitialize {
    STK_RUN_BLOCK(self.initialisationCompletion, YES, nil);
    self.initialisationCompletion = nil;
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    error ? BDMLog(@"Vungle initialisation failed with error: %@", error) : nil;
    STK_RUN_BLOCK(self.initialisationCompletion, YES, error);
    self.initialisationCompletion = nil;
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable
                      placementID:(NSString *)placementID
                            error:(NSError *)error {
    if (error) {
        NSError *wrapper = [error bdm_wrappedWithCode:BDMErrorCodeHeaderBiddingNetwork];
        STK_RUN_BLOCK([self.completionByPlacement objectForKey:placementID], nil, wrapper);
        [self.completionByPlacement removeObjectForKey:placementID];
    }
    
    for (BDMVungleFullscreenAdapter *adapter in self.delegates.allObjects.reverseObjectEnumerator) {
        [adapter vungleAdPlayabilityUpdate:isAdPlayable
                               placementID:placementID
                                     error:error];
    }
}

- (void)vungleWillShowAdForPlacementID:(NSString *)placementID {
    for (BDMVungleFullscreenAdapter *adapter in self.delegates.allObjects.reverseObjectEnumerator) {
        [adapter vungleWillShowAdForPlacementID: placementID];
    }
}

- (void)vungleWillCloseAdForPlacementID:(NSString *)placementID {
    for (BDMVungleFullscreenAdapter *adapter in self.delegates.allObjects.reverseObjectEnumerator) {
        [adapter vungleWillCloseAdForPlacementID:placementID];
    }
}

- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID {
    for (BDMVungleFullscreenAdapter *adapter in self.delegates.allObjects.reverseObjectEnumerator) {
        [adapter vungleTrackClickForPlacementID:placementID];
    }
}

- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID {
    for (BDMVungleFullscreenAdapter *adapter in self.delegates.allObjects.reverseObjectEnumerator) {
        [adapter vungleRewardUserForPlacementID:placementID];
    }
}

#pragma mark - VungleSDKHeaderBidding

- (void)placementWillBeginCaching:(NSString *)placement
                     withBidToken:(NSString *)bidToken {
    // TODO:?
}

- (void)placementPrepared:(NSString *)placement
             withBidToken:(NSString *)bidToken {
    NSMutableDictionary *bidding = [NSMutableDictionary dictionaryWithCapacity:2];
    bidding[@"placement_id"] = placement;
    bidding[@"token"] = bidToken;
    STK_RUN_BLOCK([self.completionByPlacement objectForKey:placement], bidding, nil);
    [self.completionByPlacement removeObjectForKey:placement];
}

#pragma mark - Private

- (void)syncMetadata {
    // GDPR compliance
    if (BDMSdk.sharedSdk.restrictions.subjectToGDPR) {
        VungleConsentStatus status = BDMSdk.sharedSdk.restrictions.hasConsent ? VungleConsentAccepted : VungleConsentDenied;
        [VungleSDK.sharedSDK updateConsentStatus:status consentMessageVersion:@""];
    }
    
    [VungleSDK.sharedSDK setLoggingEnabled:BDMSdkLoggingEnabled];
}

@end
