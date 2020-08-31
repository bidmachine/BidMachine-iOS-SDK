//
//  BDMAmazonAdLoader.h
//  BDMAmazonAdapter
//
//  Created by Stas Kochkin on 31.08.2020.
//  Copyright © 2020 Stas Kochkin. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class BDMAmazonAdLoader;

typedef void(^BDMAmazonAdLoaderCompletion)(BDMAmazonAdLoader *_Nonnull loader,
                                           NSDictionary <NSString *, id> *_Nullable biddingParameters,
                                           NSError *_Nullable error);

@interface BDMAmazonAdLoader : NSObject

- (instancetype)initWithServerParameters:(nonnull NSDictionary <NSString *, id> *)parameters;

- (void)prepareWithCompletion:(BDMAmazonAdLoaderCompletion)completion;

@end

NS_ASSUME_NONNULL_END
