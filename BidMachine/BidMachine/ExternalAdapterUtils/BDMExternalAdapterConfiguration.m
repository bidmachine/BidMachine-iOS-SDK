//
//  BDMExternalAdapterConfiguration.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 21.01.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMExternalAdapterConfiguration.h"

#import <StackFoundation/StackFoundation.h>

NSString *const kBDMExtTestModeKey                  = @"test_mode";
NSString *const kBDMExtBaseURLKey                   = @"endpoint";
NSString *const kBDMExtUserIdKey                    = @"userId";
NSString *const kBDMExtGenderKey                    = @"gender";
NSString *const kBDMExtYearOfBirthKey               = @"yob";
NSString *const kBDMExtKeywordsKey                  = @"keywords";
NSString *const kBDMExtBCatKey                      = @"bcat";
NSString *const kBDMExtBAdvKey                      = @"badv";
NSString *const kBDMExtBAppKey                      = @"bapps";
NSString *const kBDMExtCountryKey                   = @"country";
NSString *const kBDMExtCityKey                      = @"city";
NSString *const kBDMExtZipKey                       = @"zip";
NSString *const kBDMExtStoreUrlKey                  = @"sturl";
NSString *const kBDMExtStoreIdKey                   = @"stid";
NSString *const kBDMExtPaidKey                      = @"paid";
NSString *const kBDMExtStoreCatKey                  = @"store_cat";
NSString *const kBDMExtStoreSubCatKey               = @"store_subcat";
NSString *const kBDMExtFrameworkNameKey             = @"fmw_name";

NSString *const kBDMExtCoppaKey                     = @"coppa";
NSString *const kBDMExtConsentKey                   = @"consent";
NSString *const kBDMExtGDPRKey                      = @"gdpr";
NSString *const kBDMExtConsentStringKey             = @"consent_string";
NSString *const kBDMExtCCPAStringKey                = @"ccpa_string";

NSString *const kBDMExtLatKey                       = @"lat";
NSString *const kBDMExtLonKey                       = @"lon";

NSString *const kBDMExtPublisherIdKey               = @"pubid";
NSString *const kBDMExtPublisherNameKey             = @"pubname";
NSString *const kBDMExtPublisherDomainKey           = @"pubdomain";
NSString *const kBDMExtPublisherCatKey              = @"pubcat";

NSString *const kBDMExtNetworkConfigKey             = @"mediation_config";
NSString *const kBDMExtSSPKey                       = @"ssp";

NSString *const kBDMExtWidthKey                     = @"banner_width";
NSString *const kBDMExtHeightKey                    = @"banner_height";
NSString *const kBDMExtFullscreenTypeKey            = @"ad_content_type";
NSString *const kBDMExtNativeTypeKey                = @"adunit_native_format";
NSString *const kBDMExtPriceFloorKey                = @"priceFloors";
NSString *const kBDMExtSellerKey                    = @"seller_id";
NSString *const kBDMExtLoggingKey                   = @"logging_enabled";

NSString *const kBDMExtPriceKey                     = @"bm_pf";
NSString *const kBDMExtIDKey                        = @"bm_id";
NSString *const kBDMExtTypeKey                      = @"bm_ad_type";

@implementation BDMExternalAdapterConfiguration

+ (BDMExternalAdapterConfiguration *)configurationWithJSON:(NSDictionary *)jsonConfiguration {
    return [[self alloc] initWithJSON:jsonConfiguration];
}

- (instancetype)initWithJSON:(NSDictionary *)jsonConfiguration {
    if (self = [super init]) {
        _sdkConfiguration = [self configurationWithJSON:jsonConfiguration];
        _restriction = [self restrictionWithJSON:jsonConfiguration];
        _publisherInfo = [self publisherInfoWithJSON:jsonConfiguration];
        _fullscreenType = [self fullscreenTypeWithJSON:jsonConfiguration];
        _nativeType = [self nativeTypeWithJSON:jsonConfiguration];
        _bannerSize = [self sizeWithJSON:jsonConfiguration];
        _priceFloor = [self priceFloorWithJSON:jsonConfiguration];
        _sellerId = ANY(jsonConfiguration).from(kBDMExtSellerKey).string;
        _logging = ANY(jsonConfiguration).from(kBDMExtLoggingKey).string.boolValue;
        _price = ANY(jsonConfiguration).from(kBDMExtPriceKey).string;
        _ID = ANY(jsonConfiguration).from(kBDMExtIDKey).string;
        _type = ANY(jsonConfiguration).from(kBDMExtTypeKey).string;
    }
    return self;
}

- (BDMSdkConfiguration *)configurationWithJSON:(NSDictionary *)jsonConfiguration {
    BDMSdkConfiguration *configuration = [BDMSdkConfiguration new];
    configuration.testMode = ANY(jsonConfiguration).from(kBDMExtTestModeKey).string.boolValue;
    configuration.baseURL = [NSURL stk_url:ANY(jsonConfiguration).from(kBDMExtBaseURLKey).string];
    configuration.targeting = [self targetingWithJSON:jsonConfiguration];
    configuration.ssp = ANY(jsonConfiguration).from(kBDMExtSSPKey).string;
    
    configuration.networkConfigurations = ANY(jsonConfiguration).from(kBDMExtNetworkConfigKey).flatMap(^id(NSDictionary *json){
        return [BDMAdNetworkConfiguration configurationWithJSON:json];
    }).array;
    return configuration;
}

- (BDMTargeting *)targetingWithJSON:(NSDictionary *)jsonConfiguration {
    BDMTargeting *targeting = [BDMTargeting new];
    
    NSString *userId = ANY(jsonConfiguration).from(kBDMExtUserIdKey).string;
    if (!userId) {
        userId = ANY(jsonConfiguration).from(@"user_id").string;
    }
    targeting.userId = userId;
    targeting.gender = [self userGenderFromValue:ANY(jsonConfiguration).from(kBDMExtGenderKey).string];
    targeting.yearOfBirth = ANY(jsonConfiguration).from(kBDMExtYearOfBirthKey).number;
    targeting.keywords = ANY(jsonConfiguration).from(kBDMExtKeywordsKey).string;
    targeting.blockedCategories = [self arrayOfString:ANY(jsonConfiguration).from(kBDMExtBCatKey).string];
    targeting.blockedAdvertisers = [self arrayOfString:ANY(jsonConfiguration).from(kBDMExtBAdvKey).string];
    targeting.blockedApps = [self arrayOfString:ANY(jsonConfiguration).from(kBDMExtBAppKey).string];
    targeting.country = ANY(jsonConfiguration).from(kBDMExtCountryKey).string;
    targeting.city = ANY(jsonConfiguration).from(kBDMExtCityKey).string;
    targeting.zip = ANY(jsonConfiguration).from(kBDMExtZipKey).string;
    targeting.storeURL = [NSURL stk_url:ANY(jsonConfiguration).from(kBDMExtStoreUrlKey).string];
    targeting.storeId = ANY(jsonConfiguration).from(kBDMExtStoreIdKey).string;
    targeting.paid = ANY(jsonConfiguration).from(kBDMExtPaidKey).string.boolValue;
    targeting.storeCategory = ANY(jsonConfiguration).from(kBDMExtStoreCatKey).string;
    targeting.storeSubcategory = [self arrayOfString:ANY(jsonConfiguration).from(kBDMExtStoreSubCatKey).string];
    targeting.frameworkName = ANY(jsonConfiguration).from(kBDMExtFrameworkNameKey).string;
    targeting.deviceLocation = [self locationWithJSON:jsonConfiguration];
    
    return targeting;
}

- (BDMUserRestrictions *)restrictionWithJSON:(NSDictionary *)jsonConfiguration {
    BDMUserRestrictions *restriction = [BDMUserRestrictions new];
    restriction.coppa = ANY(jsonConfiguration).from(kBDMExtCoppaKey).string.boolValue;
    restriction.hasConsent = ANY(jsonConfiguration).from(kBDMExtConsentKey).string.boolValue;
    restriction.subjectToGDPR = ANY(jsonConfiguration).from(kBDMExtGDPRKey).string.boolValue;
    restriction.consentString = ANY(jsonConfiguration).from(kBDMExtConsentStringKey).string;
    restriction.USPrivacyString = ANY(jsonConfiguration).from(kBDMExtCCPAStringKey).string;
    return restriction;
}

- (BDMPublisherInfo *)publisherInfoWithJSON:(NSDictionary *)jsonConfiguration {
    BDMPublisherInfo *publisherInfo = [BDMPublisherInfo new];
    publisherInfo.publisherId = ANY(jsonConfiguration).from(kBDMExtPublisherIdKey).string;
    publisherInfo.publisherName = ANY(jsonConfiguration).from(kBDMExtPublisherNameKey).string;
    publisherInfo.publisherDomain = ANY(jsonConfiguration).from(kBDMExtPublisherDomainKey).string;
    publisherInfo.publisherCategories = [self arrayOfString:ANY(jsonConfiguration).from(kBDMExtPublisherCatKey).string];
    return publisherInfo;
}

- (NSArray <NSString *> *)arrayOfString:(NSString *)stringArray {
    return stringArray ? [stringArray componentsSeparatedByString:@","] : nil;
}

- (BDMUserGender *)userGenderFromValue:(NSString *)gender {
    BDMUserGender *userGender;
    if ([gender isEqualToString:@"F"]) {
        userGender = kBDMUserGenderFemale;
    } else if ([gender isEqualToString:@"M"]) {
        userGender = kBDMUserGenderMale;
    } else {
        userGender = kBDMUserGenderUnknown;
    }
    return userGender;
}

- (BDMFullscreenAdType)fullscreenTypeWithJSON:(NSDictionary *)jsonConfiguration {
    BDMFullscreenAdType type;
    NSString *lowercasedString = [ANY(jsonConfiguration).from(kBDMExtFullscreenTypeKey).string lowercaseString];
    if ([lowercasedString isEqualToString:@"all"]) {
        type = BDMFullscreenAdTypeAll;
    } else if ([lowercasedString isEqualToString:@"video"]) {
        type = BDMFullscreenAdTypeVideo;
    } else if ([lowercasedString isEqualToString:@"static"]) {
        type = BDMFullsreenAdTypeBanner;
    } else {
        type = BDMFullscreenAdTypeAll;
    }
    return type;
}

- (BDMNativeAdType)nativeTypeWithJSON:(NSDictionary *)jsonConfiguration {
    BDMNativeAdType type;
    NSString *lowercasedString = [ANY(jsonConfiguration).from(kBDMExtNativeTypeKey).string lowercaseString];
    if ([lowercasedString isEqualToString:@"all"]) {
        type = BDMNativeAdTypeAllMedia;
    } else if ([lowercasedString isEqualToString:@"video"]) {
        type = BDMNativeAdTypeVideo;
    } else if ([lowercasedString isEqualToString:@"image"]) {
        type = BDMNativeAdTypeImage;
    } else if ([lowercasedString isEqualToString:@"icon"]) {
        type = BDMNativeAdTypeIcon;
    } else {
        type = BDMNativeAdTypeAllMedia;
    }
    return type;
}

- (CGSize)sizeWithJSON:(NSDictionary *)jsonConfiguration {
    CGFloat width = ANY(jsonConfiguration).from(kBDMExtWidthKey).number.floatValue;
    CGFloat height = ANY(jsonConfiguration).from(kBDMExtHeightKey).number.floatValue;
    return CGSizeMake(width, height);
}

- (CLLocation *)locationWithJSON:(NSDictionary *)jsonConfiguration {
    NSNumber *lat = ANY(jsonConfiguration).from(kBDMExtLatKey).number;
    NSNumber *lon = ANY(jsonConfiguration).from(kBDMExtLonKey).number;
    if (!lat && !lon) {
        return nil;
    }
    return [[CLLocation alloc] initWithLatitude:lat.doubleValue longitude:lon.doubleValue];
}

- (NSArray<BDMPriceFloor *> *)priceFloorWithJSON:(NSDictionary *)jsonConfiguration {
    return ANY(jsonConfiguration).from(kBDMExtPriceFloorKey).flatMap(^id(id obj){
        if ([obj isKindOfClass:NSDictionary.class]) {
            BDMPriceFloor *priceFloor = [BDMPriceFloor new];
            NSDictionary *object = (NSDictionary *)obj;
            [priceFloor setID: object.allKeys[0]];
            [priceFloor setValue: object.allValues[0]];
            return priceFloor;
        } else if ([obj isKindOfClass:NSNumber.class]) {
            BDMPriceFloor *priceFloor = [BDMPriceFloor new];
            NSNumber *value = (NSNumber *)obj;
            NSDecimalNumber *decimalValue = [NSDecimalNumber decimalNumberWithDecimal:value.decimalValue];
            [priceFloor setID:NSUUID.UUID.UUIDString.lowercaseString];
            [priceFloor setValue:decimalValue];
            return priceFloor;
        }
        return nil;
    }).array;
}

#pragma mark - reverse

- (NSDictionary *)jsonConfiguration {
    NSMutableDictionary *jsonConfiguration = [NSMutableDictionary new];
    jsonConfiguration[kBDMExtTestModeKey] = self.sdkConfiguration.testMode ? @"true" : @"false";
    jsonConfiguration[kBDMExtBaseURLKey] = self.sdkConfiguration.baseURL.absoluteString;
    jsonConfiguration[kBDMExtUserIdKey] = self.sdkConfiguration.targeting.userId;
    jsonConfiguration[kBDMExtGenderKey] = self.sdkConfiguration.targeting.gender;
    jsonConfiguration[kBDMExtYearOfBirthKey] = self.sdkConfiguration.targeting.yearOfBirth;
    jsonConfiguration[kBDMExtKeywordsKey] = self.sdkConfiguration.targeting.keywords;
    jsonConfiguration[kBDMExtBCatKey] = [self.sdkConfiguration.targeting.blockedCategories componentsJoinedByString:@","];
    jsonConfiguration[kBDMExtBAdvKey] = [self.sdkConfiguration.targeting.blockedAdvertisers componentsJoinedByString:@","];
    jsonConfiguration[kBDMExtBAppKey] = [self.sdkConfiguration.targeting.blockedApps componentsJoinedByString:@","];
    jsonConfiguration[kBDMExtCountryKey] = self.sdkConfiguration.targeting.country;
    jsonConfiguration[kBDMExtCityKey] = self.sdkConfiguration.targeting.city;
    jsonConfiguration[kBDMExtZipKey] = self.sdkConfiguration.targeting.zip;
    jsonConfiguration[kBDMExtStoreUrlKey] = self.sdkConfiguration.targeting.storeURL.absoluteString;
    jsonConfiguration[kBDMExtStoreIdKey] = self.sdkConfiguration.targeting.storeId;
    jsonConfiguration[kBDMExtPaidKey] = self.sdkConfiguration.targeting.paid ? @"true" : @"false";
    jsonConfiguration[kBDMExtStoreCatKey] = self.sdkConfiguration.targeting.storeCategory;
    jsonConfiguration[kBDMExtStoreSubCatKey] = [self.sdkConfiguration.targeting.storeSubcategory componentsJoinedByString:@","];
    jsonConfiguration[kBDMExtFrameworkNameKey] = self.sdkConfiguration.targeting.frameworkName;
    jsonConfiguration[kBDMExtCoppaKey] = self.restriction.coppa ? @"true" : @"false";
    jsonConfiguration[kBDMExtConsentKey] = self.restriction.hasConsent ? @"true" : @"false";
    jsonConfiguration[kBDMExtGDPRKey] = self.restriction.subjectToGDPR ? @"true" : @"false";
    jsonConfiguration[kBDMExtConsentStringKey] = self.restriction.consentString;
    jsonConfiguration[kBDMExtCCPAStringKey] = self.restriction.USPrivacyString;
    jsonConfiguration[kBDMExtPublisherIdKey] = self.publisherInfo.publisherId;
    jsonConfiguration[kBDMExtPublisherNameKey] = self.publisherInfo.publisherName;
    jsonConfiguration[kBDMExtPublisherDomainKey] = self.publisherInfo.publisherDomain;
    jsonConfiguration[kBDMExtPublisherCatKey] = [self.publisherInfo.publisherCategories componentsJoinedByString:@","];
    jsonConfiguration[kBDMExtSSPKey] = self.sdkConfiguration.ssp;
    jsonConfiguration[kBDMExtSellerKey] = self.sellerId;
    jsonConfiguration[kBDMExtLoggingKey] = self.logging ? @"true" : @"false";
    jsonConfiguration[kBDMExtNetworkConfigKey] = ANY(self.sdkConfiguration.networkConfigurations).flatMap(^id(BDMAdNetworkConfiguration *config){
        return config.jsonConfiguration;
    }).array;
    jsonConfiguration[kBDMExtPriceFloorKey] = ANY(self.priceFloor).flatMap(^id(BDMPriceFloor *floor){
        NSMutableDictionary *floorJson = NSMutableDictionary.new;
        floorJson[floor.ID] = floor.value;
        return floorJson;
    }).array;
    
    if (self.sdkConfiguration.targeting.deviceLocation) {
        jsonConfiguration[kBDMExtLatKey] = @(self.sdkConfiguration.targeting.deviceLocation.coordinate.latitude);
        jsonConfiguration[kBDMExtLonKey] = @(self.sdkConfiguration.targeting.deviceLocation.coordinate.longitude);
    }
    
    jsonConfiguration[kBDMExtFullscreenTypeKey] = [self fullscreenTypeStringFromType:self.fullscreenType];
    jsonConfiguration[kBDMExtNativeTypeKey] = [self nativeTypeStringFromType:self.nativeType];
    jsonConfiguration[kBDMExtWidthKey] = @(self.bannerSize.width);
    jsonConfiguration[kBDMExtHeightKey] = @(self.bannerSize.height);
    
    //    jsonConfiguration[kBDMExtPriceKey] = self.price;
    //    jsonConfiguration[kBDMExtIDKey] = self.ID;
    //    jsonConfiguration[kBDMExtTypeKey] = self.type;
    return jsonConfiguration;
}

- (NSString *)fullscreenTypeStringFromType:(BDMFullscreenAdType)type {
    switch (type) {
        case BDMFullscreenAdTypeVideo: return @"video"; break;
        case BDMFullsreenAdTypeBanner: return @"banner"; break;
        case BDMFullscreenAdTypeAll: return @"all"; break;
        default: return @"all"; break;
    }
}

- (NSString *)nativeTypeStringFromType:(BDMNativeAdType)type {
    switch (type) {
        case BDMNativeAdTypeVideo: return @"video"; break;
        case BDMNativeAdTypeIcon: return @"icon"; break;
        case BDMNativeAdTypeImage: return @"image"; break;
        case BDMNativeAdTypeAllMedia: return @"all"; break;
        default: return @"all"; break;
    }
}

@end
