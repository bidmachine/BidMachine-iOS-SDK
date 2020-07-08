//
//  HBBDMConfiguration.m
//  HBAppodealAdExchangeAdapter
//
//  Created by Stas Kochkin on 25/10/2017.
//  Copyright © 2017 Appodeal. All rights reserved.
//

#import "BDMResponse.h"
#import "BDMCreative.h"
#import "BDMProtoAPI-Umbrella.h"


@interface BDMResponse ()

@property (nonatomic, copy, readwrite) NSString * identifier;
@property (nonatomic, copy, readwrite) NSNumber * price;
@property (nonatomic, copy, readwrite) NSString * currency;
@property (nonatomic, copy, readwrite) NSString * pricingType;
@property (nonatomic, copy, readwrite) NSString * demandSource;
@property (nonatomic, copy, readwrite) NSNumber * expirationTime;
@property (nonatomic, copy, readwrite) NSString * cid;
@property (nonatomic, copy, readwrite) NSString * deal;
@property (nonatomic, copy, readwrite) NSString * purl;
@property (nonatomic, copy, readwrite) NSString * lurl;

@property (nonatomic, copy, readwrite) BDMCreative * creative;
@property (nonatomic, strong) ORTBOpenrtb * message;

@end

@implementation BDMResponse

+ (instancetype)parseFromData:(NSData *)data {
    return data.length ? [[self alloc] initWithData:data] : nil;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        // Expects that exchange always return one bid from on seat
        self.message = [ORTBOpenrtb parseFromData:data error:nil];
        ORTBResponse_Seatbid * seat = self.message.response.seatbidArray.firstObject;
        // Save seat id as demand source name
        self.demandSource = seat.seat;
        ORTBResponse_Seatbid_Bid * bid = seat.bidArray.firstObject;
        // Save response data
        self.identifier = bid.id_p;
        self.deal = bid.deal;
        self.cid = bid.cid;
        self.purl = bid.purl;
        self.lurl = bid.lurl;
        
        self.expirationTime = [@(bid.exp) isEqual:@(0)] ? [NSNumber numberWithInt:1740] : @(bid.exp);
        self.price = @(bid.price);
        // Populate creative with bid
        if (bid.media.value) {
            self.creative = [BDMCreative parseFromData:bid.media.value];
        }
    }
    return self;
}

+ (NSNumberFormatter *)decimialNumberFormatter {
    static NSNumberFormatter *_formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _formatter = [[NSNumberFormatter alloc] init];
        _formatter.numberStyle = NSNumberFormatterDecimalStyle;
        _formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    });
    return _formatter;
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    BDMResponse * copy = [BDMResponse new];
    
    copy.identifier = self.identifier;
    copy.price = self.price;
    copy.currency = self.currency;
    copy.pricingType = self.pricingType;
    copy.demandSource = self.demandSource;
    copy.expirationTime = self.expirationTime;
    copy.cid = self.cid;
    copy.deal = self.deal;
    copy.creative = self.creative;
    copy.message = self.message;
    copy.purl = self.purl;
    copy.lurl = self.lurl;
    
    return copy;
}

#pragma mark - Overriding

- (NSString *)description {
    return self.message ? [NSString stringWithFormat:@"Message: %@", self.message] : @"No content";
}

@end
