//
//  BDMExternalAdapterConfigurationProtocol.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 01.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMSdkConfiguration+HeaderBidding.h>


@protocol BDMExternalAdapterInitialConfigurationProtocol <NSObject>

@property (nonatomic, assign, readonly) BOOL logging;
@property (nonatomic, assign, readonly) BOOL testMode;
@property (nonatomic, strong, readonly) NSString *sellerId;
@property (nonatomic, strong, readonly) NSString *SSP;
@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSArray <BDMAdNetworkConfiguration *> *networkConfigs;

@end

@protocol BDMExternalAdapterTargetingConfigurationProtocol <NSObject>

@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) BDMUserGender *gender;
@property (nonatomic, strong, readonly) NSNumber *yearOfBirth;
@property (nonatomic, strong, readonly) NSString *keywords;
@property (nonatomic, strong, readonly) NSArray <NSString *> *bCats;
@property (nonatomic, strong, readonly) NSArray <NSString *> *bAdvs;
@property (nonatomic, strong, readonly) NSArray <NSString *> *bApps;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSString *city;
@property (nonatomic, strong, readonly) NSString *zip;
@property (nonatomic, strong, readonly) NSURL *storeURL;
@property (nonatomic, strong, readonly) NSString *storeId;
@property (nonatomic, assign, readonly) BOOL paid;
@property (nonatomic, strong, readonly) NSString *storeCat;
@property (nonatomic, strong, readonly) NSArray <NSString *> *storeSubCats;
@property (nonatomic, strong, readonly) BDMFmwName *frameworkName;
@property (nonatomic, strong, readonly) CLLocation *deviceLocation;

@end

@protocol BDMExternalAdapterPublisherConfigurationProtocol <NSObject>

@property (nonatomic, strong, readonly) NSString *pubId;
@property (nonatomic, strong, readonly) NSString *pubName;
@property (nonatomic, strong, readonly) NSString *pubDomain;
@property (nonatomic, strong, readonly) NSArray <NSString *> *pubCats;

@end

@protocol BDMExternalAdapterRestrictionConfigurationProtocol <NSObject>

@property (nonatomic, assign, readonly) BOOL coppa;
@property (nonatomic, assign, readonly) BOOL GDPR;
@property (nonatomic, assign, readonly) BOOL GDPRConsent;
@property (nonatomic, strong, readonly) NSString *GDPRConsentString;
@property (nonatomic, strong, readonly) NSString *CCPAConsentString;

@end

@protocol BDMExternalAdapterRequestConfigurationProtocol <NSObject>

@property (nonatomic, strong, readonly) NSString *requestId;
@property (nonatomic, strong, readonly) NSString *requestType;
@property (nonatomic, strong, readonly) NSString *requestPrice;
@property (nonatomic, strong, readonly) NSArray <BDMPriceFloor *> *priceFloors;

@property (nonatomic, assign, readonly) CGSize adSize;
@property (nonatomic, assign, readonly) BDMNativeAdType nativeAdType;
@property (nonatomic, assign, readonly) BDMFullscreenAdType fullscreenType;

@end
