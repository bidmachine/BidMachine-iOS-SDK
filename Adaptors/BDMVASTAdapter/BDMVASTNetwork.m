//
//  BDMVASTNetwork.h
//  BDMVASTNetwork
//
//  Created by Pavel Dunyashev on 24/09/2018.
//  Copyright © 2018 Appodeal. All rights reserved.
//

#import "BDMVASTNetwork.h"
#import "BDMVASTVideoAdapter.h"


NSString *const BDMVASTCreativeKey                  = @"creative";
NSString *const BDMVASTMaxDurationKey               = @"max_duration";
NSString *const BDMVASTUseNativeCloseKey            = @"use_native_close";
NSString *const BDMVASTVideoSkipOffsetKey           = @"skip_offset";
NSString *const BDMVASTCompanionSkipOffsetKey       = @"companion_skip_offset";

@implementation BDMVASTNetwork

#pragma mark - BDMNetwork

- (NSString *)name {
    return @"vast";
}

- (NSString *)sdkVersion {
    return @"1.3.18";
}

- (id<BDMFullscreenAdapter>)videoAdapterForSdk:(BDMSdk *)sdk {
    return [BDMVASTVideoAdapter new];
}


@end

