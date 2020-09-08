//
//  BDMNASTNetwork.m
//  BDMNASTAdapter
//
//  Created by Stas Kochkin on 04/11/2018.
//  Copyright © 2018 Stas Kochkin. All rights reserved.
//

#import "BDMNASTNetwork.h"
#import "BDMNASTNativeAdServiceAdapter.h"


@implementation BDMNASTNetwork

- (NSString *)name {
    return @"nast";
}

- (NSString *)sdkVersion {
    return @"2.0";
}

- (id<BDMNativeAdServiceAdapter>)nativeAdAdapterForSdk:(BDMSdk *)sdk {
    return [BDMNASTNativeAdServiceAdapter new];
}

@end
