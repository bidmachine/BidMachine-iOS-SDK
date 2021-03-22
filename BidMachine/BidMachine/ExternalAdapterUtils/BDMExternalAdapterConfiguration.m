//
//  BDMExternalAdapterConfiguration.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 21.01.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMExternalAdapterConfiguration.h"
#import "BDMExternalAdapterConfigurationDefines.h"

#import <StackFoundation/StackFoundation.h>

NSString *const kBDMExtPriceKey                     = @"bm_pf";
NSString *const kBDMExtIDKey                        = @"bm_id";
NSString *const kBDMExtTypeKey                      = @"bm_ad_type";


@interface BDMAdNetworkConfiguration (BDMConfiguration)

+ (instancetype)configurationWithJSON:(NSDictionary <NSString *, id> *)dict;

- (NSDictionary *)jsonConfiguration;

@end


@interface BDMExternalAdapterConfigurationBuilder: NSObject <BDMExternalAdapterConfigurationBuilderProtocol>

@property (nonatomic, strong) NSMutableDictionary *configuration;

@end

@implementation BDMExternalAdapterConfigurationBuilder

- (instancetype)init {
    if (self = [super init]) {
        _configuration = NSMutableDictionary.new;
    }
    return self;
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSURL * _Nonnull))appendBaseURL {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSURL *value){
        self.configuration[kBDMExtBaseURLKey] = value.absoluteString;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendSellerId {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtSellerKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(BOOL))appendLoggingMode {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (BOOL value){
        self.configuration[kBDMExtLoggingKey] = [self stringFromBool:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(BOOL))appendTestMode {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (BOOL value){
        self.configuration[kBDMExtTestModeKey] = [self stringFromBool:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendSSP {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtSSPKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSArray<BDMAdNetworkConfiguration *> * _Nonnull))appendNetworkConfigs {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSArray<BDMAdNetworkConfiguration *> *value){
        self.configuration[kBDMExtNetworkConfigKey] = ANY(value).flatMap(^id(BDMAdNetworkConfiguration *config){
            return config.jsonConfiguration;
        }).array;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendUserId {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtUserIdKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(BDMUserGender * _Nonnull))appendGender {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtGenderKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSNumber * _Nonnull))appendYearOfBirth {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSNumber *value){
        self.configuration[kBDMExtYearOfBirthKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendKeywords {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtKeywordsKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSArray<NSString *> * _Nonnull))appendBCats {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSArray<NSString *> *value){
        self.configuration[kBDMExtBCatKey] = [self stringFromArrayOfString:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSArray<NSString *> * _Nonnull))appendBAdvs {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSArray<NSString *> *value){
        self.configuration[kBDMExtBAdvKey] = [self stringFromArrayOfString:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSArray<NSString *> * _Nonnull))appendBApps {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSArray<NSString *> *value){
        self.configuration[kBDMExtBAppKey] = [self stringFromArrayOfString:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendCountry {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtCountryKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendCity {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtCityKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendZip {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtZipKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSURL * _Nonnull))appendStoreURL {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSURL *value){
        self.configuration[kBDMExtStoreUrlKey] = value.absoluteString;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendStoreId {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtStoreIdKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(BOOL))appendPaid {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (BOOL value){
        self.configuration[kBDMExtPaidKey] = [self stringFromBool:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendStoreCat {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtStoreCatKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSArray<NSString *> * _Nonnull))appendStoreSubCats {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSArray<NSString *> *value){
        self.configuration[kBDMExtStoreSubCatKey] = [self stringFromArrayOfString:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(BDMFmwName * _Nonnull))appendFrameworkName {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtFrameworkNameKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendPubId {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtPublisherIdKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendPubDomain {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtPublisherDomainKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendPubName {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtPublisherNameKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSArray<NSString *> * _Nonnull))appendPubCats {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSArray<NSString *> *value){
        self.configuration[kBDMExtPublisherCatKey] = [self stringFromArrayOfString:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(BOOL))appendCoppa {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (BOOL value){
        self.configuration[kBDMExtCoppaKey] = [self stringFromBool:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(BOOL))appendGDPR {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (BOOL value){
        self.configuration[kBDMExtGDPRKey] = [self stringFromBool:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(BOOL))appendGDPRConsent {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (BOOL value){
        self.configuration[kBDMExtConsentKey] = [self stringFromBool:value];
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendGDPRConsentString {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtConsentStringKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSString * _Nonnull))appendCCPAConsentString {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSString *value){
        self.configuration[kBDMExtCCPAStringKey] = value;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(CLLocation * _Nonnull))appendDeviceLocation {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (CLLocation *value){
        if (value && value.coordinate.latitude != 0) {
            self.configuration[kBDMExtLatKey] = @(value.coordinate.latitude);
        }
        if (value && value.coordinate.longitude != 0) {
            self.configuration[kBDMExtLonKey] = @(value.coordinate.longitude);
        }
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSArray<BDMPriceFloor *> * _Nonnull))appendPriceFloors {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSArray<BDMPriceFloor *> *value){
        self.configuration[kBDMExtPriceFloorKey] = ANY(value).flatMap(^id(BDMPriceFloor *floor){
            NSMutableDictionary *floorJson = NSMutableDictionary.new;
            floorJson[floor.ID] = floor.value;
            return floorJson;
        }).array;
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(CGSize))appendAdSize {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (CGSize value){
        self.configuration[kBDMExtWidthKey] = @(value.width);
        self.configuration[kBDMExtHeightKey] = @(value.height);
        return self;
    };
}

- (id<BDMExternalAdapterConfigurationBuilderProtocol>  _Nonnull (^)(NSDictionary * _Nonnull))appendJsonConfiguration {
    return ^id<BDMExternalAdapterConfigurationBuilderProtocol> (NSDictionary *value){
        [self.configuration addEntriesFromDictionary:value ?: @{}];
        return self;
    };
}

#pragma mark - Private

- (NSString *)stringFromBool:(BOOL)value {
    return value ? @"true" : nil;
}

- (NSString *)stringFromArrayOfString:(NSArray <NSString *> *)value {
    return [value componentsJoinedByString:@","];
}

@end

@interface BDMExternalAdapterConfiguration ()

@property (nonatomic, strong, readwrite) NSURL *baseURL;
@property (nonatomic, strong, readwrite) NSString *sellerId;
@property (nonatomic, assign, readwrite) BOOL logging;
@property (nonatomic, assign, readwrite) BOOL testMode;
@property (nonatomic, strong, readwrite) NSString *SSP;
@property (nonatomic, strong, readwrite) NSArray <BDMAdNetworkConfiguration *> *networkConfigs;

@property (nonatomic, strong, readwrite) NSString *userId;
@property (nonatomic, strong, readwrite) BDMUserGender *gender;
@property (nonatomic, strong, readwrite) NSNumber *yearOfBirth;
@property (nonatomic, strong, readwrite) NSString *keywords;
@property (nonatomic, strong, readwrite) NSArray <NSString *> *bCats;
@property (nonatomic, strong, readwrite) NSArray <NSString *> *bAdvs;
@property (nonatomic, strong, readwrite) NSArray <NSString *> *bApps;
@property (nonatomic, strong, readwrite) NSString *country;
@property (nonatomic, strong, readwrite) NSString *city;
@property (nonatomic, strong, readwrite) NSString *zip;
@property (nonatomic, strong, readwrite) NSURL *storeURL;
@property (nonatomic, strong, readwrite) NSString *storeId;
@property (nonatomic, assign, readwrite) BOOL paid;
@property (nonatomic, strong, readwrite) NSString *storeCat;
@property (nonatomic, strong, readwrite) NSArray <NSString *> *storeSubCats;
@property (nonatomic, strong, readwrite) BDMFmwName *frameworkName;

@property (nonatomic, strong, readwrite) NSString *pubId;
@property (nonatomic, strong, readwrite) NSString *pubName;
@property (nonatomic, strong, readwrite) NSString *pubDomain;
@property (nonatomic, strong, readwrite) NSArray <NSString *> *pubCats;

@property (nonatomic, assign, readwrite) BOOL coppa;
@property (nonatomic, assign, readwrite) BOOL GDPR;
@property (nonatomic, assign, readwrite) BOOL GDPRConsent;
@property (nonatomic, strong, readwrite) NSString *GDPRConsentString;
@property (nonatomic, strong, readwrite) NSString *CCPAConsentString;
@property (nonatomic, strong, readwrite) CLLocation *deviceLocation;

@property (nonatomic, strong, readwrite) NSString *requestId;
@property (nonatomic, strong, readwrite) NSString *requestType;
@property (nonatomic, strong, readwrite) NSString *requestPrice;
@property (nonatomic, strong, readwrite) NSArray <BDMPriceFloor *> *priceFloors;

@property (nonatomic, assign, readwrite) CGSize adSize;
@property (nonatomic, assign, readwrite) BDMNativeAdType nativeAdType;
@property (nonatomic, assign, readwrite) BDMFullscreenAdType fullscreenType;

@end

@interface BDMExternalAdapterConfiguration ()

@property (nonatomic, strong) NSDictionary *jsonConfiguration;

@end

@implementation BDMExternalAdapterConfiguration

+ (instancetype)configurationWithBuilder:(void (^)(id<BDMExternalAdapterConfigurationBuilderProtocol> _Nonnull))builder {
    BDMExternalAdapterConfigurationBuilder *configurationBuilder = BDMExternalAdapterConfigurationBuilder.new;
    builder(configurationBuilder);
    BDMExternalAdapterConfiguration *configuration = [[self alloc] initPrivatlyWithConfiguration:configurationBuilder.configuration];
    return configuration;
}

- (instancetype)initPrivatlyWithConfiguration:(NSDictionary *)configuration {
    if (self = [super init]) {
        self.jsonConfiguration = configuration ?: @{};
        [self populateInitialParams];
        [self populateTargetingParams];
        [self populateRestrictionParams];
        [self populatePublisherParams];
        [self populateRequestParams];
    }
    return self;
}

- (void)populateInitialParams {
    self.logging = ANY(self.jsonConfiguration).from(kBDMExtLoggingKey).string.boolValue;
    self.testMode = ANY(self.jsonConfiguration).from(kBDMExtTestModeKey).string.boolValue;
    self.sellerId = ANY(self.jsonConfiguration).from(kBDMExtSellerKey).string;
    self.SSP = ANY(self.jsonConfiguration).from(kBDMExtSSPKey).string;
    self.baseURL = [NSURL stk_url:ANY(self.jsonConfiguration).from(kBDMExtBaseURLKey).string];
    self.networkConfigs = ANY(self.jsonConfiguration).from(kBDMExtNetworkConfigKey).flatMap(^id(NSDictionary *json){
        return [BDMAdNetworkConfiguration configurationWithJSON:json];
    }).array;
}

- (void)populateTargetingParams {
    NSString *userId = ANY(self.jsonConfiguration).from(kBDMExtUserIdKey).string;
    if (!userId) {
        userId = ANY(self.jsonConfiguration).from(@"user_id").string;
    }
    self.userId = userId;
    self.gender = ANY(self.jsonConfiguration).from(kBDMExtGenderKey).string;
    self.yearOfBirth = ANY(self.jsonConfiguration).from(kBDMExtYearOfBirthKey).number;
    self.keywords = ANY(self.jsonConfiguration).from(kBDMExtKeywordsKey).string;
    self.bCats = [self arrayFromString:ANY(self.jsonConfiguration).from(kBDMExtBCatKey).string];
    self.bAdvs = [self arrayFromString:ANY(self.jsonConfiguration).from(kBDMExtBAdvKey).string];
    self.bApps = [self arrayFromString:ANY(self.jsonConfiguration).from(kBDMExtBAppKey).string];
    self.country = ANY(self.jsonConfiguration).from(kBDMExtCountryKey).string;
    self.city = ANY(self.jsonConfiguration).from(kBDMExtCityKey).string;
    self.zip = ANY(self.jsonConfiguration).from(kBDMExtZipKey).string;
    self.storeURL = [NSURL stk_url:ANY(self.jsonConfiguration).from(kBDMExtStoreUrlKey).string];
    self.storeId = ANY(self.jsonConfiguration).from(kBDMExtStoreIdKey).string;
    self.paid = ANY(self.jsonConfiguration).from(kBDMExtPaidKey).string.boolValue;
    self.storeCat = ANY(self.jsonConfiguration).from(kBDMExtStoreCatKey).string;
    self.storeSubCats = [self arrayFromString:ANY(self.jsonConfiguration).from(kBDMExtStoreSubCatKey).string];
    self.frameworkName = ANY(self.jsonConfiguration).from(kBDMExtFrameworkNameKey).string;
    self.deviceLocation = [self locationFromLat:ANY(self.jsonConfiguration).from(kBDMExtLatKey).number
                                            lon:ANY(self.jsonConfiguration).from(kBDMExtLonKey).number];
}

- (void)populatePublisherParams {
    self.pubId = ANY(self.jsonConfiguration).from(kBDMExtPublisherIdKey).string;
    self.pubName = ANY(self.jsonConfiguration).from(kBDMExtPublisherNameKey).string;
    self.pubDomain = ANY(self.jsonConfiguration).from(kBDMExtPublisherDomainKey).string;
    self.pubCats = [self arrayFromString:ANY(self.jsonConfiguration).from(kBDMExtPublisherCatKey).string];
}

- (void)populateRestrictionParams {
    self.coppa = ANY(self.jsonConfiguration).from(kBDMExtCoppaKey).string.boolValue;
    self.GDPR = ANY(self.jsonConfiguration).from(kBDMExtGDPRKey).string.boolValue;
    self.GDPRConsent = ANY(self.jsonConfiguration).from(kBDMExtConsentKey).string.boolValue;
    self.GDPRConsentString = ANY(self.jsonConfiguration).from(kBDMExtConsentStringKey).string;
    self.CCPAConsentString = ANY(self.jsonConfiguration).from(kBDMExtCCPAStringKey).string;
}

- (void)populateRequestParams {
    self.requestId = ANY(self.jsonConfiguration).from(kBDMExtIDKey).string;
    self.requestType = ANY(self.jsonConfiguration).from(kBDMExtTypeKey).string;
    self.requestPrice = ANY(self.jsonConfiguration).from(kBDMExtPriceKey).string;
    self.priceFloors = [self priceFloorsFrom:ANY(self.jsonConfiguration).from(kBDMExtPriceFloorKey).array];
    self.fullscreenType = [self fullscreenTypeFrom:ANY(self.jsonConfiguration).from(kBDMExtFullscreenTypeKey).string];
    self.nativeAdType = [self nativeTypeFrom:ANY(self.jsonConfiguration).from(kBDMExtNativeTypeKey).string];
    self.adSize = [self sizeFrom:ANY(self.jsonConfiguration).from(kBDMExtWidthKey).number
                          height:ANY(self.jsonConfiguration).from(kBDMExtHeightKey).number];
}

#pragma mark - private

- (NSArray <NSString *> *)arrayFromString:(NSString *)value {
    return value ? [value componentsSeparatedByString:@","] : nil;
}

- (CGSize)sizeFrom:(NSNumber *)width height:(NSNumber *)height {
    return CGSizeMake(width.floatValue, height.floatValue);
}

- (CLLocation *)locationFromLat:(NSNumber *)lat lon:(NSNumber *)lon {
    if (!lat && !lon) {
        return nil;
    }
    return [[CLLocation alloc] initWithLatitude:lat.doubleValue longitude:lon.doubleValue];
}

- (NSArray<BDMPriceFloor *> *)priceFloorsFrom:(NSArray *)value {
    return ANY(value).flatMap(^id(id obj){
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

- (BDMFullscreenAdType)fullscreenTypeFrom:(NSString *)value {
    BDMFullscreenAdType type;
    NSString *lowercasedString = [value lowercaseString];
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

- (BDMNativeAdType)nativeTypeFrom:(NSString *)value {
    BDMNativeAdType type;
    NSString *lowercasedString = [value lowercaseString];
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

@end

@implementation BDMAdNetworkConfiguration (BDMConfiguration)

+ (instancetype)configurationWithJSON:(NSDictionary <NSString *, id> *)dict {
    return [BDMAdNetworkConfiguration buildWithBuilder:^(BDMAdNetworkConfigurationBuilder *builder) {
        // Append network name
        if ([dict[@"network"] isKindOfClass:NSString.class]) {
            builder.appendName(dict[@"network"]);
        }
        // Append network class
        if ([dict[@"network_class"] isKindOfClass:NSString.class]) {
            builder.appendNetworkClass(NSClassFromString(dict[@"network_class"]));
        }
        // Append ad units
        NSArray <NSDictionary *> *adUnits = dict[@"ad_units"];
        if ([adUnits isKindOfClass:NSArray.class]) {
            [adUnits enumerateObjectsUsingBlock:^(NSDictionary *adUnit, NSUInteger idx, BOOL *stop) {
                if ([adUnit isKindOfClass:NSDictionary.class]) {
                    BDMAdUnitFormat fmt = [adUnit[@"format"] isKindOfClass:NSString.class] ?
                    BDMAdUnitFormatFromString(adUnit[@"format"]) :
                    BDMAdUnitFormatUnknown;
                    NSMutableDictionary *params = adUnit.mutableCopy;
                    [params removeObjectForKey:@"format"];
                    builder.appendAdUnit(fmt, params, nil);
                }
            }];
        }
        // Append init params
        NSMutableDictionary <NSString *, id> *customParams = dict.mutableCopy;
        [customParams removeObjectsForKeys:@[
                                             @"network",
                                             @"network_class",
                                             @"ad_units"
                                             ]];
        if (customParams.count) {
            builder.appendInitializationParams(customParams);
        }
    }];
}

- (NSDictionary *)jsonConfiguration {
    NSMutableDictionary *configuration = NSMutableDictionary.new;
    configuration[@"network"] = self.name;
    configuration[@"network_class"] = NSStringFromClass(self.networkClass);
    [configuration addEntriesFromDictionary: self.initializationParams ?: @{}];
    configuration[@"ad_units"] = ANY(self.adUnits).flatMap(^id(BDMAdUnit *unit){
        NSMutableDictionary *adUnitJson = NSMutableDictionary.new;
        adUnitJson[@"format"] = NSStringFromBDMAdUnitFormat(unit.format);
        [adUnitJson addEntriesFromDictionary: unit.customParams ?: @{}];
        return adUnitJson;
    }).array;
    return configuration;
}

@end
