//
//  BDMUserRestrictions.m
//  BidMachine
//
//  Created by Stas Kochkin on 08/11/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMUserRestrictions.h"

NSString * const BDMCCPAConsentCode  = @"1y";
NSString * const BDMCCPANegativeCode = @"1n";

@interface BDMUserRestrictions ()

@property (nonatomic, copy) NSString *publisherDefinedUSPrivacyString;
@property (nonatomic, copy) NSString *publisherDefinedConsentString;
@property (nonatomic, assign) BOOL publisherDefinedSubjectToGDPR;

@property (atomic, copy) NSString *userDefaultsUSPrivacyString;
//v1
@property (atomic, copy) NSString *userDefaultsConsentString;
@property (atomic, assign) BOOL userDefaultsSubjectToGDPR;
//v2
@property (atomic, copy) NSString *userDefaultsTCFConsentString;
@property (atomic, assign) BOOL userDefaultsTCFSubjectToGDPR;

@end

@implementation BDMUserRestrictions

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userDefaultsUSPrivacyString    = [NSUserDefaults.standardUserDefaults objectForKey:@"IABUSPrivacy_String"];
        //v1
        self.userDefaultsSubjectToGDPR      = [NSUserDefaults.standardUserDefaults boolForKey:@"IABConsent_SubjectToGDPR"];
        self.userDefaultsConsentString      = [NSUserDefaults.standardUserDefaults objectForKey:@"IABConsent_ConsentString"];
        //v2
        self.userDefaultsTCFSubjectToGDPR   = [NSUserDefaults.standardUserDefaults boolForKey:@"IABTCF_gdprApplies"];
        self.userDefaultsTCFConsentString   = [NSUserDefaults.standardUserDefaults objectForKey:@"IABTCF_TCString"];
        self.coppa = NO;
        [self observeUserDefaults];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeUserDefaults {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChangeNotification:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
}

- (void)userDefaultsDidChangeNotification:(NSNotification *)notification {
    NSUserDefaults *defaults = (NSUserDefaults *)[notification object];
    self.userDefaultsUSPrivacyString = [defaults objectForKey:@"IABUSPrivacy_String"];
    //v1
    self.userDefaultsSubjectToGDPR = [defaults boolForKey:@"IABConsent_SubjectToGDPR"];
    self.userDefaultsConsentString = [defaults objectForKey:@"IABConsent_ConsentString"];
    //v2
    self.userDefaultsTCFSubjectToGDPR   = [defaults boolForKey:@"IABTCF_gdprApplies"];
    self.userDefaultsTCFConsentString   = [defaults objectForKey:@"IABTCF_TCString"];
}

- (void)setConsentString:(NSString *)consentString {
    self.publisherDefinedConsentString = consentString;
}

- (void)setSubjectToGDPR:(BOOL)subjectToGDPR {
    self.publisherDefinedSubjectToGDPR = subjectToGDPR;
}

- (void)setUSPrivacyString:(NSString *)USPrivacyString {
    self.publisherDefinedUSPrivacyString = USPrivacyString;
}

- (NSString *)consentString {
    NSString *defaults = self.userDefaultsTCFConsentString ?: self.userDefaultsConsentString;
    return self.publisherDefinedConsentString ?: defaults;
}

- (BOOL)subjectToGDPR {
    return self.publisherDefinedSubjectToGDPR || self.userDefaultsTCFSubjectToGDPR || self.userDefaultsSubjectToGDPR;
}

- (NSString *)USPrivacyString {
    return self.publisherDefinedUSPrivacyString ?: self.userDefaultsUSPrivacyString;
}

- (BOOL)hasCCPAConsent {
    return [self.CCPACode isEqualToString:BDMCCPAConsentCode];
}

- (BOOL)subjectToCCPA {
    return [@[BDMCCPAConsentCode, BDMCCPANegativeCode] containsObject:self.CCPACode ?: @"Undefined"];
}

- (BOOL)allowUserInformation {
    return !self.coppa && (!self.subjectToGDPR || self.hasConsent);
}

- (NSString *)CCPACode {
    NSString *code;
    if (self.USPrivacyString.length == 4) {
        char consentChar = [self.USPrivacyString.lowercaseString characterAtIndex:2];
        char versionChar = [self.USPrivacyString.lowercaseString characterAtIndex:0];
        code = [NSString stringWithFormat:@"%c,%c", versionChar, consentChar];
        code = code.lowercaseString;
    }
    return code;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    BDMUserRestrictions *restrictionsCopy = [BDMUserRestrictions new];
    
    restrictionsCopy.publisherDefinedConsentString   = self.publisherDefinedConsentString;
    restrictionsCopy.publisherDefinedSubjectToGDPR   = self.publisherDefinedSubjectToGDPR;
    restrictionsCopy.publisherDefinedUSPrivacyString = self.publisherDefinedUSPrivacyString;
    restrictionsCopy.coppa                           = self.coppa;
    restrictionsCopy.hasConsent                      = self.hasConsent;
    
    return restrictionsCopy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.publisherDefinedConsentString forKey:@"consentString"];
    [aCoder encodeBool:self.publisherDefinedSubjectToGDPR forKey:@"subjectToGDPR"];
    [aCoder encodeObject:self.publisherDefinedUSPrivacyString forKey:@"USPrivacyString"];
    [aCoder encodeBool:self.coppa forKey:@"coppa"];
    [aCoder encodeBool:self.hasConsent forKey:@"hasConsent"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.publisherDefinedConsentString   = [aDecoder decodeObjectForKey:@"consentString"];
        self.publisherDefinedSubjectToGDPR   = [aDecoder decodeBoolForKey:@"subjectToGDPR"];
        self.publisherDefinedUSPrivacyString = [aDecoder decodeObjectForKey:@"USPrivacyString"];
        self.coppa                           = [aDecoder decodeBoolForKey:@"coppa"];
        self.hasConsent                      = [aDecoder decodeBoolForKey:@"hasConsent"];
    }
    return self;
}

@end
