//
//  BDMAmazonValueTransformer.m
//  BDMAmazonAdapter
//
//  Created by Yaroslav Skachkov on 9/12/19.
//  Copyright © 2019 Stas Kochkin. All rights reserved.
//

#import "BDMAmazonValueTransformer.h"

@implementation BDMAmazonValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:NSString.class]) {
        return value;
    } else if ([value isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)value stringValue];
    }
    return nil;
}

@end
