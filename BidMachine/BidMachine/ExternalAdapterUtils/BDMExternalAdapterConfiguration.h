//
//  BDMExternalAdapterConfiguration.h
//  BidMachine
//
//  Created by Ilia Lozhkin on 21.01.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMSdkConfiguration+HeaderBidding.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const kBDMExtTestModeKey;
FOUNDATION_EXPORT NSString *const kBDMExtBaseURLKey;
FOUNDATION_EXPORT NSString *const kBDMExtUserIdKey;
FOUNDATION_EXPORT NSString *const kBDMExtGenderKey;
FOUNDATION_EXPORT NSString *const kBDMExtYearOfBirthKey;
FOUNDATION_EXPORT NSString *const kBDMExtKeywordsKey;
FOUNDATION_EXPORT NSString *const kBDMExtBCatKey;
FOUNDATION_EXPORT NSString *const kBDMExtBAdvKey;
FOUNDATION_EXPORT NSString *const kBDMExtBAppKey;
FOUNDATION_EXPORT NSString *const kBDMExtCountryKey;
FOUNDATION_EXPORT NSString *const kBDMExtCityKey;
FOUNDATION_EXPORT NSString *const kBDMExtZipKey;
FOUNDATION_EXPORT NSString *const kBDMExtStoreUrlKey;
FOUNDATION_EXPORT NSString *const kBDMExtStoreIdKey;
FOUNDATION_EXPORT NSString *const kBDMExtPaidKey;
FOUNDATION_EXPORT NSString *const kBDMExtStoreCatKey;
FOUNDATION_EXPORT NSString *const kBDMExtStoreSubCatKey;
FOUNDATION_EXPORT NSString *const kBDMExtFrameworkNameKey;

FOUNDATION_EXPORT NSString *const kBDMExtCoppaKey;
FOUNDATION_EXPORT NSString *const kBDMExtConsentKey;
FOUNDATION_EXPORT NSString *const kBDMExtGDPRKey;
FOUNDATION_EXPORT NSString *const kBDMExtConsentStringKey;
FOUNDATION_EXPORT NSString *const kBDMExtCCPAStringKey;

FOUNDATION_EXPORT NSString *const kBDMExtLatKey;
FOUNDATION_EXPORT NSString *const kBDMExtLonKey;

FOUNDATION_EXPORT NSString *const kBDMExtPublisherIdKey;
FOUNDATION_EXPORT NSString *const kBDMExtPublisherNameKey;
FOUNDATION_EXPORT NSString *const kBDMExtPublisherDomainKey;
FOUNDATION_EXPORT NSString *const kBDMExtPublisherCatKey;

FOUNDATION_EXPORT NSString *const kBDMExtNetworkConfigKey;
FOUNDATION_EXPORT NSString *const kBDMExtSSPKey;

FOUNDATION_EXPORT NSString *const kBDMExtWidthKey;
FOUNDATION_EXPORT NSString *const kBDMExtHeightKey;
FOUNDATION_EXPORT NSString *const kBDMExtFullscreenTypeKey;
FOUNDATION_EXPORT NSString *const kBDMExtNativeTypeKey;
FOUNDATION_EXPORT NSString *const kBDMExtPriceFloorKey;
FOUNDATION_EXPORT NSString *const kBDMExtSellerKey;
FOUNDATION_EXPORT NSString *const kBDMExtLoggingKey;

@interface BDMExternalAdapterConfiguration : NSObject

@property (nonatomic, strong) BDMSdkConfiguration *sdkConfiguration;
@property (nonatomic, strong) BDMUserRestrictions *restriction;
@property (nonatomic, strong) BDMPublisherInfo *publisherInfo;
@property (nonatomic, strong) NSArray <BDMPriceFloor *> *priceFloor;
@property (nonatomic, strong) NSString *sellerId;
@property (nonatomic, assign) BOOL logging;

@property (nonatomic, assign) BDMFullscreenAdType fullscreenType;
@property (nonatomic, assign) BDMNativeAdType nativeType;
@property (nonatomic, assign) CGSize bannerSize;

@property (nonatomic, strong, readonly) NSString *price;
@property (nonatomic, strong, readonly) NSString *ID;
@property (nonatomic, strong, readonly) NSString *type;

+ (instancetype)configurationWithJSON:(nullable NSDictionary *)jsonConfiguration;

- (NSDictionary *)jsonConfiguration;

@end

NS_ASSUME_NONNULL_END
