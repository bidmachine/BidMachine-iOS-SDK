//
//  BDMExternalAdapterSDKController.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 02.03.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMExternalAdapterSDKController.h"

#import <StackFoundation/StackFoundation.h>

@interface BDMExternalAdapterSDKController ()

@property (nonatomic, assign) BOOL isInitilized;

@property (nonatomic, strong) BDMExternalAdapterConfiguration *localConfiguration;

@end

@implementation BDMExternalAdapterSDKController

+ (instancetype)shared {
    static BDMExternalAdapterSDKController *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}

- (void)startControllerWithConfiguration:(BDMExternalAdapterConfiguration *)configuration
                              completion:(void (^)(NSError * _Nullable))completion
{
    BDMSdk *sdk = [BDMSdk sharedSdk];
    if (self.isInitilized == NO) {
        if ([sdk isInitialized]) {
            self.isInitilized = YES;
            self.localConfiguration = [self configurationFromSDK:BDMSdk.sharedSdk];
            [self updateSDK:sdk withConfiguration:configuration];
            STK_RUN_BLOCK(completion, nil);
        } else {
            [self initializeSDK:sdk configuration:configuration completion:^(NSError *error) {
                if (error) {
                    STK_RUN_BLOCK(completion, error);
                } else {
                    self.isInitilized = YES;
                    self.localConfiguration = configuration;
                    STK_RUN_BLOCK(completion, nil);
                }
            }];
        }
    } else {
        [self updateSDK:sdk withConfiguration:configuration];
        STK_RUN_BLOCK(completion, nil);
    }
}

- (void)initializeSDK:(BDMSdk *)sdk
        configuration:(BDMExternalAdapterConfiguration *)configuration
           completion:(void (^)(NSError * _Nullable))completion
{
    if (!NSString.stk_isValid(configuration.sellerId)) {
        NSError *error = [STKError errorWithDescription:@"The sellerId is nil or not valid string"];
        STK_RUN_BLOCK(completion, error);
        return;
    }
    
    // Create required Objects
    BDMSdkConfiguration *sdkConfiguration   = BDMSdkConfiguration.new;
    sdkConfiguration.targeting              = BDMTargeting.new;
    sdk.publisherInfo                       = BDMPublisherInfo.new;
    
    // Populate from configuration
    [self populateSDK:sdk withConfiguration:configuration];
    [self populatePublisher:sdk.publisherInfo withConfiguration:configuration];
    [self populateRestrinction:sdk.restrictions withConfiguration:configuration];
    [self populateTargeting:sdkConfiguration.targeting withConfiguration:configuration];
    [self populateSDKConfiguration:sdkConfiguration withConfiguration:configuration];
    
    // Set network config only for initializing
    sdkConfiguration.networkConfigurations = configuration.networkConfigs;
    // Start Session with configuration
    [sdk startSessionWithSellerID:configuration.sellerId
                    configuration:sdkConfiguration
                       completion:^{ STK_RUN_BLOCK(completion, nil); }];
}

- (void)updateSDK:(BDMSdk *)sdk withConfiguration:(BDMExternalAdapterConfiguration *)configuration {
    BDMExternalAdapterConfiguration *config = [BDMExternalAdapterConfiguration configurationWithBuilder:^(id<BDMExternalAdapterConfigurationBuilderProtocol> builder) {
        builder.appendJsonConfiguration(configuration.jsonConfiguration);
        builder.appendJsonConfiguration(self.localConfiguration.jsonConfiguration);
    }];
    
    sdk.publisherInfo = sdk.publisherInfo ?: BDMPublisherInfo.new;
    sdk.configuration.targeting = sdk.configuration.targeting ?: BDMTargeting.new;
    
    [self populateSDK:sdk withConfiguration:config];
    [self populateSDK:sdk withConfiguration:config];
    [self populatePublisher:sdk.publisherInfo withConfiguration:config];
    [self populateRestrinction:sdk.restrictions withConfiguration:config];
    [self populateTargeting:sdk.configuration.targeting withConfiguration:config];
    [self populateSDKConfiguration:sdk.configuration withConfiguration:config];
}

- (void)populateSDK:(BDMSdk *)sdk withConfiguration:(BDMExternalAdapterConfiguration *)configuration {
    sdk.enableLogging = configuration.logging;
}

- (void)populateSDKConfiguration:(BDMSdkConfiguration *)sdkConfiguration withConfiguration:(BDMExternalAdapterConfiguration *)configuration {
    sdkConfiguration.testMode = configuration.testMode;
    sdkConfiguration.baseURL = configuration.baseURL;
    sdkConfiguration.ssp = configuration.SSP;
}

- (void)populateTargeting:(BDMTargeting *)targeting withConfiguration:(BDMExternalAdapterConfiguration *)configuration {
    targeting.userId = configuration.userId;
    targeting.gender = configuration.gender;
    targeting.yearOfBirth = configuration.yearOfBirth;
    targeting.keywords = configuration.keywords;
    targeting.blockedCategories = configuration.bCats;
    targeting.blockedAdvertisers = configuration.bAdvs;
    targeting.blockedApps = configuration.bApps;
    targeting.country = configuration.country;
    targeting.city = configuration.city;
    targeting.zip = configuration.zip;
    targeting.storeURL = configuration.storeURL;
    targeting.storeId = configuration.storeId;
    targeting.paid = configuration.paid;
    targeting.storeCategory = configuration.storeCat;
    targeting.storeSubcategory = configuration.storeSubCats;
    targeting.frameworkName = configuration.frameworkName;
    targeting.deviceLocation = configuration.deviceLocation;
}

- (void)populatePublisher:(BDMPublisherInfo *)publisher withConfiguration:(BDMExternalAdapterConfiguration *)configuration {
    publisher.publisherId = configuration.pubId;
    publisher.publisherName = configuration.pubName;
    publisher.publisherDomain = configuration.pubDomain;
    publisher.publisherCategories = configuration.pubCats;
}

- (void)populateRestrinction:(BDMUserRestrictions *)restriction withConfiguration:(BDMExternalAdapterConfiguration *)configuration {
    restriction.coppa = configuration.coppa;
    restriction.subjectToGDPR = configuration.GDPR;
    restriction.hasConsent = configuration.GDPRConsent;
    restriction.consentString = configuration.GDPRConsentString;
    restriction.USPrivacyString = configuration.CCPAConsentString;
}

#pragma mark - Private

- (BDMExternalAdapterConfiguration *)configurationFromSDK:(BDMSdk *)sdk {
    // copy all parameters wo (sellerId and networkConfigs)
    return [BDMExternalAdapterConfiguration configurationWithBuilder:^(id<BDMExternalAdapterConfigurationBuilderProtocol> builder) {
        builder
        .appendLoggingMode(sdk.enableLogging)
        .appendTestMode(sdk.configuration.testMode)
        .appendSSP(sdk.configuration.ssp)
        .appendBaseURL(sdk.configuration.baseURL)
        
        .appendUserId(sdk.configuration.targeting.userId)
        .appendGender(sdk.configuration.targeting.gender)
        .appendYearOfBirth(sdk.configuration.targeting.yearOfBirth)
        .appendKeywords(sdk.configuration.targeting.keywords)
        .appendBCats(sdk.configuration.targeting.blockedCategories)
        .appendBAdvs(sdk.configuration.targeting.blockedAdvertisers)
        .appendBApps(sdk.configuration.targeting.blockedApps)
        .appendCountry(sdk.configuration.targeting.country)
        .appendCity(sdk.configuration.targeting.city)
        .appendZip(sdk.configuration.targeting.zip)
        .appendStoreURL(sdk.configuration.targeting.storeURL)
        .appendStoreId(sdk.configuration.targeting.storeId)
        .appendPaid(sdk.configuration.targeting.paid)
        .appendStoreCat(sdk.configuration.targeting.storeCategory)
        .appendStoreSubCats(sdk.configuration.targeting.storeSubcategory)
        .appendFrameworkName(sdk.configuration.targeting.frameworkName)
        .appendDeviceLocation(sdk.configuration.targeting.deviceLocation)
        
        .appendPubId(sdk.publisherInfo.publisherId)
        .appendPubName(sdk.publisherInfo.publisherName)
        .appendPubDomain(sdk.publisherInfo.publisherDomain)
        .appendPubCats(sdk.publisherInfo.publisherCategories)
        
        .appendCoppa(sdk.restrictions.coppa)
        .appendGDPR(sdk.restrictions.subjectToGDPR)
        .appendGDPRConsent(sdk.restrictions.hasConsent)
        .appendGDPRConsentString(sdk.restrictions.consentString)
        .appendCCPAConsentString(sdk.restrictions.USPrivacyString);
    }];
}

@end
