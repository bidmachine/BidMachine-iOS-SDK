//
//  BDMExternalAdapterKeywordsTransformer.m
//  BidMachine
//
//  Created by Ilia Lozhkin on 02.02.2021.
//  Copyright © 2021 Appodeal. All rights reserved.
//

#import "BDMExternalAdapterKeywordsTransformer.h"

@implementation BDMExternalAdapterKeywordsTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if (![value isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSMutableArray *keywords = [NSMutableArray arrayWithCapacity:[(NSDictionary *)value count]];
    [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        NSString *keyword = [NSString stringWithFormat:@"%@:%@", key, obj];
        [keywords addObject:keyword];
    }];
    
    return [keywords componentsJoinedByString:@","];
}

@end
