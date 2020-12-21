//
//  BDMAdUnit.m
//  BidMachine
//
//  Created by Stas Kochkin on 18/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMAdUnit.h"


@interface BDMAdUnit ()

@property (nonatomic, assign, readwrite) BDMAdUnitFormat format;
@property (nonatomic, copy,   readwrite) BDMStringToStringMap *params;
@property (nonatomic, copy,   readwrite) BDMStringToObjectMap *extras;

@end


@implementation BDMAdUnit

+ (instancetype)adUnitWithFormat:(BDMAdUnitFormat)format
                          params:(BDMStringToStringMap *)params
                          extras:(BDMStringToObjectMap *)extras {
    return [[self alloc] initWithFormat:format
                                 params:params
                                 extras:extras];
}

- (instancetype)initWithFormat:(BDMAdUnitFormat)format
                        params:(BDMStringToStringMap *)params
                        extras:(BDMStringToObjectMap *)extras {
    if (self = [super init]) {
        self.format = format;
        self.params = params;
        self.extras = extras;
    }
    return self;
}

#pragma mark - Coding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.format forKey:@"format"];
    [aCoder encodeObject:self.extras forKey:@"extras"];
    [aCoder encodeObject:self.params forKey:@"params"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    BDMAdUnitFormat format = [aDecoder decodeIntegerForKey:@"format"];
    NSDictionary *extras = [aDecoder decodeObjectForKey:@"extras"];
    NSDictionary *params = [aDecoder decodeObjectForKey:@"params"];
    return [self initWithFormat:format params:params extras:extras];
}

#pragma mark - Coping

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithFormat:self.format
                                       params:self.params
                                       extras:self.extras];
}

#pragma mark - Equals

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:BDMAdUnit.class] &&
    [(BDMAdUnit *)object format] == self.format &&
    [[(BDMAdUnit *)object params] isEqual:self.params] &&
    [[(BDMAdUnit *)object extras] isEqual:self.extras];
}

@end

