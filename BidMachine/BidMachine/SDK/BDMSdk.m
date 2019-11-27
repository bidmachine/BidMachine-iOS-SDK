//
//  BDMSdk.m
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMSdk.h"
#import "BDMSdk+Project.h"
#import "BDMSdkConfiguration+HeaderBidding.h"

#import "BDMRegistry.h"
#import "BDMFactory.h"
#import "BDMAsyncOperation.h"
#import "BDMFactory+BDMOperation.h"
#import "BDMHeaderBiddingInitialisationOperation.h"
#import "BDMHeaderBiddingPreparationOperation.h"
#import "BDMViewabilityMetricAppodeal.h"
#import "BDMServerCommunicator.h"
#import "BDMRetryTimer.h"
#import "BDMAuctionSettings.h"
#import "BDMEventMiddleware.h"

#import <StackFoundation/StackFoundation.h>


@interface BDMSdk () <BDMHeaderBiddingControllerDelegate>

@property (nonatomic, assign, readwrite, getter=isInitialized) BOOL initialized;

@property (nonatomic, strong) BDMRegistry *registry;
@property (nonatomic, strong) BDMEventMiddleware *middleware;
@property (nonatomic, strong) BDMRetryTimer *retryTimer;
@property (nonatomic, strong) STKNetworkReachability *reachability;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) BDMHeaderBiddingController *headerBiddingController;

@property (nonatomic, copy) NSString *sellerID;
@property (nonatomic, copy) BDMSdkConfiguration *configuration;
@property (nonatomic, strong) BDMOpenRTBAuctionSettings *auctionSettings;

@end

@implementation BDMSdk

+ (instancetype)sharedSdk {
    static BDMSdk * _sharedSDK;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSDK = [[BDMSdk alloc] initPrivately];
    });
    return _sharedSDK;
}

- (instancetype)initPrivately {
    self = [super init];
    if (self) {
        // Create registry
        self.auctionSettings    = [BDMOpenRTBAuctionSettings defaultAuctionSettings];
        self.registry           = [BDMFactory.sharedFactory registry];
        // Register viewability
        [BDMViewabilityMetricProvider registerMetric:BDMViewabilityMetricAppodeal.class];
    }
    return self;
}

- (BOOL)testMode {
    return self.configuration.testMode;
}

- (NSURL *)baseURL {
    return self.configuration.baseURL;
}

- (void)setEnableLogging:(BOOL)enableLogging {
    _enableLogging = enableLogging;
    BDMSdkLoggingEnabled = enableLogging;
}

- (void)startSessionWithSellerID:(NSString *)sellerID
                      completion:(void (^)(void))completion {
    BDMSdkConfiguration * configuration = [BDMSdkConfiguration new];
    
    [self startSessionWithSellerID:sellerID
                     configuration:configuration
                        completion:completion];
}

- (void)startSessionWithSellerID:(NSString *)sellerID
                   configuration:(BDMSdkConfiguration *)configuration
                      completion:(void (^)(void))completion {
    // Seller ID check
    if (!sellerID.length) {
        BDMLog(@"Seller ID should be valid string. Sdk was not initialized properly, see docs: https://wiki.appodeal.com/display/BID/BidMachine+iOS+SDK+Documentation");
        return;
    }
    
    // Start location manager
    if (STKLocation.locationTrackingEnabled) {
        [STKLocation startMonitoring];
    }
    
    // Just save data
    self.sellerID = sellerID;
    self.configuration = configuration;
    
    // Parallel bidding
    [self registerNetworks];
    [self.registry initNetworks];
    
    NSArray <BDMAdNetworkConfiguration *> *networkConfigs = self.configuration.networkConfigurations;
    if (!networkConfigs.count) {
        self.initialized = YES;
        STK_RUN_BLOCK(completion);
    } else {
        [self initializeNetworks:networkConfigs
                      completion:completion];
    }
    
    if (self.retryTimer) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.retryTimer = BDMRetryTimer.timer(^(BDMRetryTimer *timer){
        // Register initialisation event
        [weakSelf.middleware startEvent:BDMEventInitialisation];
        
        [BDMServerCommunicator.sharedCommunicator makeInitRequest:^(BDMSessionBuilder *builder) {
            builder
            .appendBaseURL(weakSelf.configuration.baseURL)
            .appendSellerID(weakSelf.sellerID)
            .appendTargeting(weakSelf.configuration.targeting);
        } success:^(id<BDMInitialisationResponse> response) {
            // Save auction config
            if (response.auctionURL) {
                weakSelf.auctionSettings.auctionURL = response.auctionURL.absoluteString;
            }
            weakSelf.auctionSettings.eventURLs = response.eventURLs;
            // Fulfill initialisation
            [weakSelf.middleware fulfillEvent:BDMEventInitialisation];
            timer.stop();
        } failure:^(NSError *error) {
            // Reject initialisation
            [weakSelf.middleware rejectEvent:BDMEventAuction code:error.code];
            // Repeat action
            timer.repeat();
        }];
    });
    self.retryTimer.start();
}

- (STKNetworkReachability *)reachability {
    if (!_reachability) {
        NSString * host = [NSURL URLWithString:self.auctionSettings.auctionURL].host;
        _reachability = [[STKNetworkReachability alloc] initWithHost:host];
    }
    return _reachability;
}

- (BDMHeaderBiddingController *)headerBiddingController {
    if (!_headerBiddingController) {
        _headerBiddingController = [BDMHeaderBiddingController new];
        _headerBiddingController.delegate = self;
        _headerBiddingController.middleware = self.middleware;
    }
    return _headerBiddingController;
}

- (BOOL)isDeviceReachable {
    return self.reachability.status != STKNetworkStatusNotReachability;
}

#pragma mark - Private

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [BDMFactory.sharedFactory operationQueue];
        _operationQueue.maxConcurrentOperationCount = 1;
        _operationQueue.qualityOfService = NSQualityOfServiceUtility;
    }
    return _operationQueue;
}

- (BDMEventMiddleware *)middleware {
    if (!_middleware) {
        _middleware = [BDMEventMiddleware buildMiddleware:^(BDMEventMiddlewareBuilder *builder) {
            __weak typeof(self) weakSelf = self;
            builder.events(^NSArray<BDMEventURL *> *{
                return weakSelf.auctionSettings.eventURLs;
            });
        }];
    }
    return _middleware;
}

#pragma mark - BDMHeaderBiddingControllerDelegate

- (id<BDMNetwork>)networkWithName:(NSString *)name controller:(BDMHeaderBiddingController *)controller {
    return [self.registry networkByName:name];
}

@end


@implementation BDMSdk (Project)

#pragma mark - BDMSdkContext

- (id <BDMBannerAdapter>)bannerAdapterForNetwork:(NSString *)networkName {
    return [self.registry bannerAdapterForNetwork:networkName];
}

- (id <BDMFullscreenAdapter>)interstitialAdAdapterForNetwork:(NSString *)networkName {
    return [self.registry interstitialAdAdapterForNetwork:networkName];
}

- (id <BDMFullscreenAdapter>)videoAdapterForNetwork:(NSString *)networkName {
    return [self.registry videoAdapterForNetwork:networkName];
}

- (id <BDMNativeAdServiceAdapter>)nativeAdAdapterForNetwork:(NSString *)networkName {
    return [self.registry nativeAdAdapterForNetwork:networkName];
}

- (BDMTargeting *)targeting {
    return self.configuration.targeting;
}

#pragma mark - BDMSdkHeaderBiddingContext

- (NSString *)ssp {
    return self.configuration.ssp;
}

- (void)registerNetworks {
    // Register networks first
    NSArray <NSString *> *embeddedNetworks = @[ @"BDMMRAIDNetwork", @"BDMVASTNetwork", @"BDMNASTNetwork" ];
    NSMutableArray <Class<BDMNetwork>> *networkClasses = ANY(self.configuration.networkConfigurations)
    .flatMap(^id(BDMAdNetworkConfiguration *config){
        return config.networkClass;
    }).array.mutableCopy ?: [NSMutableArray arrayWithCapacity:3];
    
    [embeddedNetworks enumerateObjectsUsingBlock:^(NSString *networkClassString, NSUInteger idx, BOOL *stop) {
        Class <BDMNetwork> cls = NSClassFromString(networkClassString);
        if ([cls conformsToProtocol:@protocol(BDMNetwork)]) {
            [networkClasses addObject:cls];
        }
    }];
    
    [networkClasses enumerateObjectsUsingBlock:^(Class<BDMNetwork> network, NSUInteger idx, BOOL *stop) {
        [self.registry registerNetworkClass:network];
    }];
}

- (void)initializeNetworks:(NSArray <BDMAdNetworkConfiguration *> *)configs
                completion:(void(^)(void))completion {
    BDMHeaderBiddingInitialisationOperation *operation = [BDMFactory.sharedFactory initialisationOperationForNetworks:configs
                                                                                                           controller:self.headerBiddingController
                                                                                                    waitUntilFinished:NO];
    __weak typeof(self) weakSelf = self;
    operation.completionBlock = ^{
        weakSelf.initialized = YES;
        completion ? dispatch_async(dispatch_get_main_queue(), completion) : nil;
    };
    [self.operationQueue addOperation:operation];
}

- (void)collectHeaderBiddingAdUnits:(BDMInternalPlacementType)placementType
                         completion:(void (^)(NSArray<id<BDMPlacementAdUnit>> *))completion {
    [self.middleware startEvent:BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared
                      placement:placementType];
    BDMHeaderBiddingInitialisationOperation *initialisation = [BDMFactory.sharedFactory initialisationOperationForNetworks:self.configuration.networkConfigurations
                                                                                                                controller:self.headerBiddingController
                                                                                                         waitUntilFinished:YES];
    BDMHeaderBiddingPreparationOperation *preparation = [BDMFactory.sharedFactory preparationOperationForNetworks:self.configuration.networkConfigurations
                                                                                                       controller:self.headerBiddingController
                                                                                                        placement:placementType];
    [preparation addDependency:initialisation];
    __weak typeof(preparation) weakPreparation = preparation;
    __weak typeof(self) weakSelf = self;
    preparation.completionBlock = ^{
        [weakSelf.middleware fulfillEvent:BDMEventHeaderBiddingAllHeaderBiddingNetworksPrepared
                                placement:placementType];
        STK_RUN_BLOCK(completion, weakPreparation.result);
    };
    [self.operationQueue addOperation:initialisation];
    [self.operationQueue addOperation:preparation];
}

@end
