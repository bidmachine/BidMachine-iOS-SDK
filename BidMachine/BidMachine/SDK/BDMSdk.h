//
//  BDMSdk.h
//  BidMachine
//
//  Created by Stas Kochkin on 07/11/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMPublisherInfo.h>
#import <BidMachine/BDMSdkConfiguration.h>

/**
 Proxy object that provides communication between bidding and networks adapter
 */
@interface BDMSdk : NSObject
/**
 Boolean getter that indicates if sdk is ready for auction
 */
@property (nonatomic, assign, readonly, getter=isInitialized) BOOL initialized;
/**
 Enables logging. Logging is disabled by default
 */
@property (nonatomic, assign, readwrite) BOOL enableLogging;
/**
 Restrictions
 */
@property (copy, nonatomic, readonly, nonnull) BDMUserRestrictions *restrictions;
/**
 Publisher info
 */
@property (copy, nonatomic, readwrite, nullable) BDMPublisherInfo *publisherInfo;

+ (nonnull instancetype)new NS_UNAVAILABLE;
- (nonnull instancetype)init NS_UNAVAILABLE;
/**
 Singleton sdk object
 
 @return Shared instance
 */
+ (nonnull instancetype)sharedSdk;
/**
 Starts session with publisher id
 
 @param sellerID Your seller id provided by BidMachine
 @param completion Called when sdk completes initialisation
 */
- (void)startSessionWithSellerID:(nonnull NSString *)sellerID
                      completion:(void(^ _Nullable)(void))completion;
/**
 Starts session with publisher id and configured start data
 
 @param sellerID Your seller id provided by BidMachine
 @param configuration Initial configuration
 @param completion Called when sdk completes initialisation
 */
- (void)startSessionWithSellerID:(nonnull NSString *)sellerID
                   configuration:(nonnull BDMSdkConfiguration *)configuration
                      completion:(void(^ _Nullable)(void))completion;

@end
