//
//  BDMTargeting.h
//  BidMachine
//
//  Created by Stas Kochkin on 03/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BidMachine/BDMDefines.h>
#import <BidMachine/BDMUserRestrictions.h>
#import <CoreLocation/CoreLocation.h>


BDM_SUBCLASSING_RESTRICTED

@interface BDMExternalUserId : NSObject <NSCopying, NSSecureCoding>

@property (copy, nonatomic, readwrite, nullable) NSString *sourceId;
@property (copy, nonatomic, readwrite, nullable) NSString *value;

@end

/// Targeting model for SDK
@interface BDMTargeting : NSObject <NSCopying, NSSecureCoding>
/// Vendor-specific ID for the user
@property (copy, nonatomic, readwrite, nonnull) NSString *userId;
/// User gender in OpenRTB 2.5 format
@property (copy, nonatomic, readwrite, nonnull) BDMUserGender *gender;
///  User gender yob in OpenRTB 2.5 format
@property (copy, nonatomic, readwrite, nonnull) NSNumber *yearOfBirth;
///  User age
@property (copy, nonatomic, readonly, nullable) NSNumber *userAge;
/// Custom user params
@property (copy, nonatomic, readwrite, nullable) NSArray<BDMExternalUserId *> *externalUserIds;
/// Comma separated list of keywords about the app
@property (copy, nonatomic, readwrite, nullable) NSString *keywords;
/// List of blocked advertiser categories using the IAB content categories.
@property (copy, nonatomic, readwrite, nullable) NSArray <NSString *> *blockedCategories;
/// List of blocked advertisers by their domains (e.g., “ford.com”).
@property (copy, nonatomic, readwrite, nullable) NSArray <NSString *> *blockedAdvertisers;
/// List of blocked applications by their platform-specific exchange-independent application identifiers. Usually store IDs.
@property (copy, nonatomic, readwrite, nullable) NSArray <NSString *> *blockedApps;
/// Current location of user device. If location services enabled in application, sdk will take location by itself
@property (copy, nonatomic, readwrite, nullable) CLLocation *deviceLocation;
/// User country
@property (copy, nonatomic, readwrite, nullable) NSString *country;
/// User city
@property (copy, nonatomic, readwrite, nullable) NSString *city;
/// User zip code
@property (copy, nonatomic, readwrite, nullable) NSString *zip;
/// App's Store URL
@property (copy, nonatomic, readwrite, nullable) NSURL *storeURL;
/// Numeric store id identifier
@property (copy, nonatomic, readwrite, nullable) NSString *storeId;
/// Paid version of app
@property (assign, nonatomic, readwrite) BOOL paid;
/// Apple App Store category definitions. For example, "games"
@property (copy, nonatomic, readwrite, nullable) NSString *storeCategory;
/// Apple App Store Sub category definitions. The array is always capped at 3 strings.
@property (copy, nonatomic, readwrite, nullable) NSArray <NSString *> *storeSubcategory;
/// A string value describing if the app is using the unity or native
@property (copy, nonatomic, readwrite, nullable) BDMFmwName *frameworkName;

@end
