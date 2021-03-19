//
//  BDMExternalAdapterConfigurationBuilderProtocol.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 01.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMSdkConfiguration+HeaderBidding.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BDMExternalAdapterConfigurationBuilderProtocol <NSObject>

@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendSellerId)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendLoggingMode)(BOOL);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendTestMode)(BOOL);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendBaseURL)(NSURL *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendUserId)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendGender)(BDMUserGender *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendYearOfBirth)(NSNumber *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendKeywords)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendBCats)(NSArray <NSString *> *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendBAdvs)(NSArray <NSString *> *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendBApps)(NSArray <NSString *> *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendCountry)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendCity)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendZip)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendStoreURL)(NSURL *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendStoreId)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendPaid)(BOOL);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendStoreCat)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendStoreSubCats)(NSArray <NSString *> *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendFrameworkName)(BDMFmwName *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendCoppa)(BOOL);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendGDPR)(BOOL);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendGDPRConsent)(BOOL);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendGDPRConsentString)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendCCPAConsentString)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendDeviceLocation)(CLLocation *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendPubId)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendPubName)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendPubDomain)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendPubCats)(NSArray <NSString *> *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendNetworkConfigs)(NSArray <BDMAdNetworkConfiguration *> *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendSSP)(NSString *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendAdSize)(CGSize);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendPriceFloors)(NSArray <BDMPriceFloor *> *);
@property (nonatomic, readonly) id<BDMExternalAdapterConfigurationBuilderProtocol>(^appendJsonConfiguration)(NSDictionary *__nullable);

@end

NS_ASSUME_NONNULL_END
