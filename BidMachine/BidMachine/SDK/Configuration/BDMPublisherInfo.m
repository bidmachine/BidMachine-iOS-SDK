//
//  BDMPublisherInfo.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 12/4/19.
//  Copyright © 2019 Appodeal. All rights reserved.
//

#import "BDMPublisherInfo.h"

@implementation BDMPublisherInfo

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    BDMPublisherInfo * publisherInfo = [BDMPublisherInfo new];
    publisherInfo.publisherId           = self.publisherId;
    publisherInfo.publisherName         = self.publisherName;
    publisherInfo.publisherDomain       = self.publisherDomain;
    publisherInfo.publisherCategories   = self.publisherCategories;
    return publisherInfo;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.publisherId forKey:@"publisherId"];
    [coder encodeObject:self.publisherName forKey:@"publisherName"];
    [coder encodeObject:self.publisherDomain forKey:@"publisherDomain"];
    [coder encodeObject:self.publisherCategories forKey:@"publisherCategories"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        _publisherId = [coder decodeObjectForKey:@"publisherId"];
        _publisherName = [coder decodeObjectForKey:@"publisherName"];
        _publisherDomain = [coder decodeObjectForKey:@"publisherDomain"];
        _publisherCategories = [coder decodeObjectForKey:@"publisherCategories"];
    }
    return self;
}

@end
