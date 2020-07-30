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
@property (nonatomic, copy, readwrite) NSDictionary <NSString *, id> *initializationParams;
@property (nonatomic, copy, readwrite) NSArray <BDMAdUnit *> *adUnits;
@property (nonatomic, assign, readwrite) NSTimeInterval timeout;

- (instancetype)initWithBuilder:(BDMAdNetworkConfigurationBuilder *)builder;

@end


@interface BDMAdNetworkConfigurationBuilder ()

@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) Class<BDMNetwork> networkClass;
@property (nonatomic, copy, readwrite) NSDictionary <NSString *, id> *initializationParams;
@property (nonatomic, copy, readwrite) NSMutableArray <BDMAdUnit *> *units;
@property (nonatomic, assign, readwrite) NSTimeInterval preparationTimeout;

@end 


@implementation BDMAdNetworkConfigurationBuilder

- (instancetype)init {
    if (self = [super init]) {
        // TODO: Timeout for all ad types is 5 sec
        self.preparationTimeout = 5000;
    }
    return self;
}

- (BDMAdNetworkConfigurationBuilder *(^)(NSString *))appendName {
    return ^id(NSString *name) {
        self.name = name;
        return self;
    };
}

- (NSMutableArray<BDMAdUnit *> *)units {
    if (!_units) {
        _units = [NSMutableArray new];
    }
    return _units;
}

- (BDMAdNetworkConfigurationBuilder * (^)(BDMAdUnitFormat, NSDictionary<NSString *,id> *))appendAdUnit {
    return ^id(BDMAdUnitFormat fmt, NSDictionary *params) {
        BDMAdUnit *unit = [BDMAdUnit adUnitWithFormat:fmt customParams:params];
        if (![self.units containsObject:unit]) {
            [self.units addObject:unit];
        }
        return self;
    };
}

- (BDMAdNetworkConfigurationBuilder *(^)(Class<BDMNetwork>))appendNetworkClass {
    return ^id(Class<BDMNetwork> cls) {
        self.networkClass = cls;
        return self;
    };
}

- (BDMAdNetworkConfigurationBuilder *(^)(NSDictionary<NSString *,id> *))appendInitializationParams {
    return ^id(NSDictionary<NSString *,id> *params) {
        self.initializationParams = params;
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
        self.name = builder.name;
        self.networkClass = builder.networkClass;
        self.initializationParams = builder.initializationParams;
        self.adUnits = builder.units;
        self.timeout = builder.preparationTimeout;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:NSStringFromClass(self.networkClass) forKey:@"networkClass"];
    [aCoder encodeObject:self.initializationParams forKey:@"params"];
    [aCoder encodeObject:self.adUnits forKey:@"ad_units"];
    [aCoder encodeDouble:self.timeout forKey:@"timeout"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name                               = [aDecoder decodeObjectForKey:@"name"];
        self.networkClass                       = [aDecoder decodeObjectForKey:@"networkClass"] ? NSClassFromString([aDecoder decodeObjectForKey:@"networkClass"]) : nil;
        self.initializationParams               = [aDecoder decodeObjectForKey:@"params"];
        self.adUnits                            = [aDecoder decodeObjectForKey:@"ad_units"];
        self.timeout                            = [aDecoder decodeDoubleForKey:@"timeout"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [BDMAdNetworkConfiguration buildWithBuilder:^(BDMAdNetworkConfigurationBuilder *builder) {
        builder.appendName(self.name);
        builder.appendInitializationParams(self.initializationParams);
        builder.appendNetworkClass(self.networkClass);
        [self.adUnits enumerateObjectsUsingBlock:^(BDMAdUnit *obj, NSUInteger idx, BOOL *stop) {
            builder.appendAdUnit(obj.format, obj.customParams);
        }];
    }];
}

@end
