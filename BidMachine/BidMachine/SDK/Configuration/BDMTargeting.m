//
//  BDMTargeting.m
//  BidMachine
//
//  Created by Stas Kochkin on 03/10/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMTargeting.h"

@implementation BDMExternalUserId

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BDMExternalUserId * externalUserIdCopy = [BDMExternalUserId new];
    
    externalUserIdCopy.sourceId                = self.sourceId;
    externalUserIdCopy.value                   = self.value;
    return externalUserIdCopy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.sourceId forKey:@"sourceId"];
    [aCoder encodeObject:self.value forKey:@"value"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.sourceId                = [aDecoder decodeObjectForKey:@"sourceId"];
        self.value                   = [aDecoder decodeObjectForKey:@"value"];
    }
    return self;
}

@end

@implementation BDMTargeting

- (instancetype)init {
    self = [super init];
    if (self) {
        self.gender = kBDMUserGenderUnknown;
        self.yearOfBirth = @(kBDMUndefinedYearOfBirth);
    }
    return self;
}

- (NSNumber *)userAge {
    NSInteger yob = self.yearOfBirth.unsignedIntegerValue;
    NSInteger age = 0;
    if (yob > 0) {
        NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSInteger year = [gregorian component:NSCalendarUnitYear fromDate:NSDate.date];
        age = year - yob;
    }
    return @(age);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BDMTargeting * targetingCopy = [BDMTargeting new];
    
    targetingCopy.userId                = self.userId;
    targetingCopy.gender                = self.gender;
    targetingCopy.yearOfBirth           = self.yearOfBirth;
    targetingCopy.externalUserIds       = self.externalUserIds;
    targetingCopy.keywords              = self.keywords;
    targetingCopy.blockedCategories     = self.blockedCategories;
    targetingCopy.blockedAdvertisers    = self.blockedAdvertisers;
    targetingCopy.blockedApps           = self.blockedApps;
    targetingCopy.deviceLocation        = self.deviceLocation;
    targetingCopy.country               = self.country;
    targetingCopy.city                  = self.city;
    targetingCopy.zip                   = self.zip;
    targetingCopy.paid                  = self.paid;
    targetingCopy.storeURL              = self.storeURL;
    targetingCopy.storeId               = self.storeId;
    targetingCopy.storeCategory         = self.storeCategory;
    targetingCopy.storeSubcategory      = self.storeSubcategory;
    targetingCopy.frameworkName         = self.frameworkName;
    
    return targetingCopy;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.yearOfBirth forKey:@"yearOfBirth"];
    [aCoder encodeObject:self.externalUserIds forKey:@"externalUserIds"];
    [aCoder encodeObject:self.keywords forKey:@"keywords"];
    [aCoder encodeObject:self.blockedCategories forKey:@"blockedCategories"];
    [aCoder encodeObject:self.blockedAdvertisers forKey:@"blockedAdvertisers"];
    [aCoder encodeObject:self.blockedApps forKey:@"blockedApps"];
    [aCoder encodeObject:self.deviceLocation forKey:@"location"];
    [aCoder encodeObject:self.country forKey:@"country"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.zip forKey:@"zip"];
    [aCoder encodeObject:self.storeURL forKey:@"storeURL"];
    [aCoder encodeInteger:self.paid forKey:@"paid"];
    [aCoder encodeObject:self.storeId forKey:@"storeId"];
    [aCoder encodeObject:self.storeCategory forKey:@"storeCategory"];
    [aCoder encodeObject:self.storeSubcategory forKey:@"storeSubcategory"];
    [aCoder encodeObject:self.frameworkName forKey:@"frameworkName"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userId                = [aDecoder decodeObjectForKey:@"userId"];
        self.gender                = [aDecoder decodeObjectForKey:@"gender"];
        self.yearOfBirth           = [aDecoder decodeObjectForKey:@"yearOfBirth"];
        self.externalUserIds       = [aDecoder decodeObjectForKey:@"externalUserIds"];
        self.keywords              = [aDecoder decodeObjectForKey:@"keywords"];
        self.blockedCategories     = [aDecoder decodeObjectForKey:@"blockedCategories"];
        self.blockedAdvertisers    = [aDecoder decodeObjectForKey:@"blockedAdvertisers"];
        self.blockedApps           = [aDecoder decodeObjectForKey:@"blockedApps"];
        self.deviceLocation        = [aDecoder decodeObjectForKey:@"location"];
        self.country               = [aDecoder decodeObjectForKey:@"country"];
        self.city                  = [aDecoder decodeObjectForKey:@"city"];
        self.zip                   = [aDecoder decodeObjectForKey:@"zip"];
        self.storeURL              = [aDecoder decodeObjectForKey:@"storeURL"];
        self.paid                  = [aDecoder decodeIntegerForKey:@"paid"];
        self.storeId               = [aDecoder decodeObjectForKey:@"storeId"];
        self.storeCategory         = [aDecoder decodeObjectForKey:@"storeCategory"];
        self.storeSubcategory      = [aDecoder decodeObjectForKey:@"storeSubcategory"];
        self.frameworkName         = [aDecoder decodeObjectForKey:@"frameworkName"];
    }
    return self;
}

@end
