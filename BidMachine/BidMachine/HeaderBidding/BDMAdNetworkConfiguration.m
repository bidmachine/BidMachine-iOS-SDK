//
//  BDMAdNetworkConfiguration.m
//  BidMachine
//
//  Created by Stas Kochkin on 17/07/2019.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMAdNetworkConfiguration.h"


@interface BDMAdNetworkConfiguration ()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) Class<BDMNetwork> networkClass;
@property (nonatomic, copy, readwrite) BDMStringToStringMap *params;
@property (nonatomic, copy, readwrite) NSArray <BDMAdUnit *> *adUnits;
@property (nonatomic, assign, readwrite) NSTimeInterval timeout;

@end


@interface BDMAdNetworkConfigurationBuilder ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) Class<BDMNetwork> networkClass;
@property (nonatomic, strong, readwrite) NSDictionary <NSString *, id> *params;
@property (nonatomic, strong, readwrite) NSMutableArray <BDMAdUnit *> *units;
@property (nonatomic, assign, readwrite) NSTimeInterval timeout;

@end 


@implementation BDMAdNetworkConfigurationBuilder

- (instancetype)init {
    if (self = [super init]) {
        self.timeout = 5000;
        self.units = NSMutableArray.new;
    }
    return self;
}

#pragma mark - Builders

- (BDMAdNetworkConfigurationBuilder *(^)(NSString *))appendName {
    return ^id(NSString *name) {
        self.name = name;
        return self;
    };
}

- (BDMAdNetworkConfigurationBuilder * (^)(NSTimeInterval))appendTimeout {
    return ^id(NSTimeInterval timeout){
        self.timeout = timeout;
        return self;
    };
}

- (BDMAdNetworkConfigurationBuilder *(^)(Class<BDMNetwork>))appendNetworkClass {
    return ^id(Class<BDMNetwork> cls) {
        self.networkClass = cls;
        return self;
    };
}

- (BDMAdNetworkConfigurationBuilder *(^)(BDMStringToStringMap *))appendParams {
    return ^id(BDMStringToStringMap *params) {
        self.params = params;
        return self;
    };
}

- (BDMAdNetworkConfigurationBuilder *(^)(BDMAdUnitFormat, BDMStringToStringMap *, BDMStringToObjectMap *))appendAdUnit {
    return ^id(BDMAdUnitFormat fmt, BDMStringToStringMap *params, BDMStringToObjectMap *extras) {
        BDMAdUnit *unit = [BDMAdUnit adUnitWithFormat:fmt params:params extras:extras];
        if (![self.units containsObject:unit]) {
            [self.units addObject:unit];
        }
        return self;
    };
}

@end


@implementation BDMAdNetworkConfiguration

+ (BDMAdNetworkConfiguration *)buildWithBuilder:(void (^)(BDMAdNetworkConfigurationBuilder *))builder {
    BDMAdNetworkConfigurationBuilder *build = [BDMAdNetworkConfigurationBuilder new];
    builder(build);
    BDMAdNetworkConfiguration *config;
    if (build.name && build.networkClass) {
        config = [[self alloc] initWithBuilder:build];
    } else {
        BDMLog(@"One of required parameters does not exist: name, networkClass");
    }
    return config;
}

- (instancetype)initWithBuilder:(BDMAdNetworkConfigurationBuilder *)builder {
    if (self = [super init]) {
        self.name           = builder.name;
        self.params         = builder.params;
        self.adUnits        = builder.units;
        self.timeout        = builder.timeout;
        self.networkClass   = builder.networkClass;
    }
    return self;
}

#pragma mark - Coding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.params forKey:@"params"];
    [aCoder encodeDouble:self.timeout forKey:@"timeout"];
    [aCoder encodeObject:self.adUnits forKey:@"ad_units"];
    [aCoder encodeObject:NSStringFromClass(self.networkClass) forKey:@"networkClass"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name            = [aDecoder decodeObjectForKey:@"name"];
        self.params          = [aDecoder decodeObjectForKey:@"params"];
        self.timeout         = [aDecoder decodeDoubleForKey:@"timeout"];
        self.adUnits         = [aDecoder decodeObjectForKey:@"ad_units"];
        self.networkClass    = [aDecoder decodeObjectForKey:@"networkClass"] ? NSClassFromString([aDecoder decodeObjectForKey:@"networkClass"]) : nil;
    }
    return self;
}

#pragma mark - Coping

- (id)copyWithZone:(NSZone *)zone {
    return [BDMAdNetworkConfiguration buildWithBuilder:^(BDMAdNetworkConfigurationBuilder *builder) {
        builder.appendName(self.name);
        builder.appendParams(self.params);
        builder.appendNetworkClass(self.networkClass);
        [self.adUnits enumerateObjectsUsingBlock:^(BDMAdUnit *unit, NSUInteger idx, BOOL *stop) {
            builder.appendAdUnit(unit.format, unit.params, unit.extras);
        }];
    }];
}

@end
